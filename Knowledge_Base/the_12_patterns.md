# THE 12 PATTERNS — HARVARD DEPTH WITH EVERY INCIDENT CASE

---

## 🧭 Overview Panel
* [Pattern 1 — Observability](#pattern-1--observability)
* [Pattern 2 — Least Privilege](#pattern-2--least-privilege)
* [Pattern 3 — Pipeline](#pattern-3--pipeline)
* [Pattern 4 — Progressive Delivery](#pattern-4--progressive-delivery)
* [Pattern 5 — Secret Management](#pattern-5--secret-management)
* [Pattern 6 — Idempotency](#pattern-6--idempotency)
* [Pattern 8 — Auto-Scaling](#pattern-8--auto-scaling)
* [Pattern 9 — Event-Driven](#pattern-9--event-driven)
* [Pattern 10 — Immutable Infrastructure](#pattern-10--immutable-infrastructure)
* [Pattern 11 — Defence in Depth](#pattern-11--defence-in-depth)
* [Pattern 12 — Cost Control (FinOps)](#pattern-12--cost-control-finops)

---

## 🌳 Pattern Hierarchy Flowchart

```mermaid
graph TD
    Root[The 12 Patterns] --> P1[1. Observability]
    Root --> P2[2. Least Privilege]
    Root --> P3[3. Pipeline]
    Root --> P4[4. Progressive Delivery]
    Root --> P5[5. Secret Management]
    Root --> P6[6. Idempotency]
    Root --> P8[8. Auto-Scaling]
    Root --> P9[9. Event-Driven]
    Root --> P10[10. Immutable Infrastructure]
    Root --> P11[11. Defence in Depth]
    Root --> P12[12. Cost Control]

    style Root fill:#f9f,stroke:#333,stroke-width:4px

    PATTERN 1 — OBSERVABILITY

The prerequisite for all other patterns. Without observability, all debugging is guessing.
The Three-Layer Model
Component	Answers...	Characteristics
Metrics	Is something wrong, and how wrong?	Aggregates over time. A metric alone cannot tell you why something is wrong. Example: CPU at 95% for 10 minutes. No process context.
Logs	What did the system do, and in what order?	Discrete events. Tells the narrative. Example: Connection refused to postgres:5432 identifies the failure location, not the scope.
Traces	Which service in a distributed system is the bottleneck?	Connects user requests across services. Example: API Gateway (3ms) → Lambda (45ms) → DynamoDB (380ms).

The Cardinal Rule: Always observe in this order:

    Metrics first to quantify scope.

    Logs second to find the specific failure.

    Traces third to locate it in the distributed system.

Every Incident Case

    High latency, no errors (P99 spiking, P50 fine): Tail latency problem. P50 fine means most requests are fast; P99 spiking means small percentages are slow. Root causes: DB lock contention, Lambda cold starts. Debug: CloudWatch → filter by endpoint → examine high duration logs. Never look at average latency.

    5xx error rate spiking but CPU/memory normal: Application-level failure. Debug: CloudWatch Logs Insights; common causes: DB connection pool exhaustion, upstream API errors, or bad deployments. Check deployment history; roll back if a deploy happened 10m before the spike.

    Memory climbing steadily, no alert triggered: Classic memory leak. Gradual upward slope = leak. Spike returning to baseline = load-driven. Lambda leaks manifest within single executions. Containers: docker stats → watch RSS. Python causes: unclosed handles, circular references. Fix: add memory limits + alarms.

    CloudWatch billing alarm fires: Cost spike = observability failure. Debug: AWS Cost Explorer → daily granularity. Causes: NAT Gateway charges (forgot VPC endpoints), ALB with no targets, unused EC2 instances. NAT Gateway and ALB are 80/20 cost drivers.

    Logs are empty when they should have content: Absence of logs is diagnostic. Causes: (1) App crashing before logging, (2) Logs to wrong stream (check IAM roles/log group), (3) Buffering. SIGKILL/OOM kills before flush. Fix: PYTHONUNBUFFERED=1.

    Intermittent errors that don't reproduce consistently: Root causes: race conditions, resource exhaustion, flaky dependencies. Debug: increase verbosity → add correlation IDs → load test. Technique: structured logging (requestId, userId) via CloudWatch Insights.

PATTERN 2 — LEAST PRIVILEGE

Every permission you grant that isn't needed is an attack surface and a debugging liability.

The Mental Model: IAM is a default-deny system. Nothing is allowed unless explicitly permitted. Dimensions: The principal (who), the action (what), the resource (which), and the condition (circumstances). Errors in any dimension cause Access Denied.
The Confusion Matrix
Error	Meaning	Where to look
AccessDenied on action	Principal lacks IAM action	Policy document; check exact action name
AccessDenied on resource	Action allowed, wrong resource ARN	Policy resource field; check ARN exactly
UnauthorizedOperation	EC2-specific, same as AccessDenied	EC2 IAM policy
InvalidClientTokenId	Wrong AWS account credentials	Check authenticated AWS account
ExpiredTokenException	Temporary credentials expired	Refresh STS token or re-assume role
Every Incident Case

    Lambda returns AccessDenied calling DynamoDB PutItem: Missing dynamodb:PutItem, wrong table ARN, or missing GSI permission. Debug: CloudTrail → filter PutItem → check denied ARN. Fix: use IAM Access Analyzer to generate minimal policy.

    GitHub Actions deployment fails with AccessDenied: Missing action. Commonly forgotten: ecs:UpdateService, ecs:RegisterTaskDefinition, iam:PassRole. Missing iam:PassRole causes confusing registration failures. Debug: CloudTrail → Client.UnauthorizedOperation.

    Cross-account S3 access denied even with bucket policy: Requires BOTH bucket policy (allow cross-account) AND the principal's IAM policy. Most common mistake is forgetting the second one. S3 Block Public Access settings override both policies.

    IAM role assumption fails: Trust policy defines who can assume it. Missing principal in trust policy causes failure even if user has sts:AssumeRole. Trust policy and identity policy must agree.

    Cognito JWT validated but Lambda still returns 403: Authorizer returns Allow, but Lambda has additional checks. Three layers: (1) Cognito user → Authorizer, (2) APIGW → Lambda invocation, (3) Lambda role → downstream. All three must be correct.

PATTERN 3 — PIPELINE

A deployment pipeline is not a convenience. It is the formal definition of what "deployed" means.

The atomic unit: A pipeline run is a single, indivisible transaction. Commit to production is all-or-nothing. Bypassable steps are not gates—they are suggestions.
Pipeline Failure Taxonomy

    Failure at trigger stage: Causes: branch filter (main vs master), aggressive path filters, event mismatch, YAML syntax errors (GitHub Actions silently ignores these). Debug: check actionlint/workflow history.

    Failure at build stage: Wrong artifact. Docker: COPY requirements.txt after COPY . . causes wrong cache invalidation. Lambda: dependencies missing or wrong runtime. Test: run in fresh environment with no local caches to find hidden dependencies.

    Failure at test stage — passes locally, fails in CI: Causes: (1) Missing environment variables (DATABASE_URL), (2) Port conflicts (8080), (3) Timezone difference (fix: TZ=UTC), (4) Filesystem path assumptions, (5) Test order dependency.

    Failure at deploy stage — deploy succeeds but app is broken: Application is in a bad state despite tool success. Causes: manual settings on old deploy not codified, stale image tags, lenient health checks, secret changes. Debug: compare container env vars; check health check body.

    Pipeline is slow (10+ minutes): Build time is an operational metric. Fixes: (1) cache ~/.cache/pip, (2) correct Docker layer order, (3) cache fixtures, (4) specify --platform, (5) parallel jobs. 80/20 rule: caching and layer order fix 70%.

    Race condition — two deploys running simultaneously: Older version finishes last and overwrites newer version. Fix: GitHub Actions concurrency groups with cancel-in-progress: true.

PATTERN 5 — SECRET MANAGEMENT

A secret that touches code, even temporarily, is a compromised secret.

GitHub scans every commit ever pushed, including deleted ones. Bots scrape credentials within seconds. Rotation is the only fix — not deletion.
Every Incident Case

    Secret committed to git: Rotate first, investigate second. Deactivate AWS keys immediately. Check CloudTrail for CreateUser or AttachUserPolicy (privilege escalation). If found, treat account as compromised.

    Application can't access Secrets Manager at startup: Causes: Missing secretsmanager:GetSecretValue, missing prefix in name, wrong AWS region. Debug: aws sts assume-role and try CLI access.

    Secret rotation breaks the application: App caches secret and doesn't refresh. Fix: refresh mechanism (cache with TTL or re-fetch on auth failure). Production pattern: fetch with 5-minute cache, invalidate on 401.

    Different secret values in different environments: Staging app connects to prod due to isolation failure. Fix: SSM Parameter Store with environment paths (/prod/ vs /staging/) and path-restricted IAM policies.

PATTERN 6 — IDEMPOTENCY

The production test: can I run this twice without breaking anything?

The three failure modes:

    Type 1 — Duplicate creation: Retry fails because resource exists (e.g., EntityAlreadyExists).

    Type 2 — Partial state: Operation fails halfway; retry produces inconsistency.

    Type 3 — Side effects that compound: Repeated runs accumulate (e.g., repeated config blocks).

Every Incident Case

    Terraform apply fails halfway: State reflects partial application. Debug: terraform plan to see missing vs existing. Review plan after failure. Don't destroy/apply if re-applying suffices.

    Bash script creates IAM user, fails on second run: Use if ! aws iam get-user ... check before creating. Check desired state before attempting creation.

    Database migration runs twice: Use CREATE TABLE IF NOT EXISTS. Migration tools break if manual changes are made to tracking tables. Fix: never run migrations manually.

    Lambda triggered twice for the same S3 event: At-least-once delivery. Fix: DynamoDB conditional writes with event ID as the key (attribute_not_exists).

    CloudFormation stack in UPDATE_ROLLBACK_FAILED: CFN can't undo changes, leaving undefined state. Fix: continue-update-rollback skipping failing resources. Terraform is preferred for state inspectability.

PATTERN 4 — PROGRESSIVE DELIVERY

Production rule: never make a change that can't be reversed in under 5 minutes.

The blast radius concept: * Blue/Green: Zero blast radius (old version stays up).

    Canary: Traffic percentages route to new version.

    Rolling updates: Updates specific pods.

Every Incident Case

    Blue/Green — new environment not healthy before switch: Shallow /health checks return 200 despite DB failure. Fix: /health/deep that queries the database.

    Canary — metric alarm didn't fire but users complain: Threshold too coarse. Fix: use statistical significance testing, not absolute thresholds.

    Rolling update leaves cluster in mixed state: User sessions load-balanced between A and B version. Fix: backward compatibility. Deploy version that handles both schemas first, then migrate.

PATTERN 8 — AUTO-SCALING

Scaling is not a feature. It is an operational discipline.
Every Incident Case

    Scale-out fires but instances aren't ready in time: Boot + App load time > Spike duration. Fix: predictive scaling, pre-warming, or pre-baked Docker images.

    Scale-in terminates an instance in the middle of processing: Long-running request killed. Fix: scale-in protection or graceful shutdown (SIGTERM) handling.

    Scaling too aggressively in both directions (thrashing): CPU spikes/drops causing constant oscillation. Fix: 5-min scale-out cooldown, 30-min scale-in cooldown. Scale fast, scale in slowly.

    K8s HPA scaling but pods are in Pending state: No node resources available. Fix: maintain buffer capacity (20% low utilization) or overprovisioning (dummy pods).

PATTERN 9 — EVENT-DRIVEN

Async is a failure isolation strategy, not just a performance optimisation.
Every Incident Case

    SQS queue depth growing, consumers not keeping up: (1) Slow consumer, (2) Consumer failing (requeuing). Check DLQ first; growing DLQ = failure, empty DLQ = throughput problem.

    Messages processed out of order (corruption): Standard SQS is best-effort. Fix: SQS FIFO with message group ID for strict user-level ordering.

    Lambda timeout shorter than SQS visibility timeout: Lambda times out; message becomes visible again while first Lambda is still working. Fix: Visibility timeout should be at least 6x Lambda timeout.

    EventBridge rule not triggering: Case-sensitive exact matching. Debug: use test event feature. Rules only specify required fields, not all fields.

PATTERN 10 — IMMUTABLE INFRASTRUCTURE

The moment you SSH into a server to fix something, you've created a snowflake.
Every Incident Case

    Server has a fix that doesn't exist in the code: Someone manually edited /etc/environment. Six months later, new AMI lacks the fix. Rule: SSH fix is temporary; permanent fix is updating IaC.

    Dockerfile uses RUN apt-get install without version pinning: Rebuild installs newer breaking version. Fix: Pin package versions (e.g., python3-pip=22.0.2+dfsg-1).

    AMI baking takes 30 minutes, deploy is blocked: Baking is slow on critical path. Fix: Docker for app code (fast builds); AMIs for rare base configuration changes.

PATTERN 11 — DEFENCE IN DEPTH

Each layer assumes all other layers have failed.
Every Incident Case

    Security group allows 22 from 0.0.0.0/0: Open to brute-force scans. Fix: Use AWS Systems Manager (SSM) Session Manager (no open ports needed).

    TLS certificate expired, service is down: Monitoring failure. Fix: CloudWatch alarm on ACM certificate days until expiry.

    DynamoDB table publicly accessible: Lambda role has dynamodb:* on * + code injection = attacker access. Fix: Table-level resource ARNs in IAM policies.

PATTERN 12 — COST CONTROL (FINOPS)

Cost is an operational metric. A system that works but costs 10x what it should is not production-ready.
Every Incident Case (Ranked by Frequency)

    NAT Gateway data processing charges: $0.045/GB. Fix: VPC endpoints for S3/DynamoDB (zero data cost).

    ALB with no healthy targets: ~$0.008/hour base charge. Fix: Tag experiments and auto-delete via weekly Lambda.

    Lambda timeout set too high: Paying for full potential execution on failed invocations. Fix: Set to 2-3x P99 execution time.

    DynamoDB provisioned capacity mode (wrong estimation): Paying for unused units. Fix: Use on-demand mode for unpredictable traffic.