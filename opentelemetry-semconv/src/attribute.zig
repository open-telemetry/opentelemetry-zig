//! Generated from OpenTelemetry semantic conventions specification v1.36.0
//! This file contains semantic convention attribute definitions.

const std = @import("std");
const types = @import("types.zig");

pub const android_app_stateValue = enum {
    created,
    background,
    foreground,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .created => "created",
            .background => "background",
            .foreground => "foreground",
        };
    }
};

/// This attribute represents the state of the application.
pub const android_app_state = types.EnumAttribute(android_app_stateValue){
    .name = "android.app.state",
    .brief = "This attribute represents the state of the application.",
    .note = "The Android lifecycle states are defined in [Activity lifecycle callbacks](https://developer.android.com/guide/components/activities/activity-lifecycle#lc), and from which the `OS identifiers` are derived.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Uniquely identifies the framework API revision offered by a version (`os.version`) of the android operating system. More information can be found [here](https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels).
pub const android_os_api_level = types.StringAttribute{
    .name = "android.os.api_level",
    .brief = "Uniquely identifies the framework API revision offered by a version (`os.version`) of the android operating system. More information can be found [here](https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const android_stateValue = enum {
    created,
    background,
    foreground,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .created => "created",
            .background => "background",
            .foreground => "foreground",
        };
    }
};

/// Deprecated. Use `android.app.state` body field instead.
pub const android_state = types.EnumAttribute(android_stateValue){
    .name = "android.state",
    .brief = "Deprecated. Use `android.app.state` body field instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A unique identifier representing the installation of an application on a specific device
pub const app_installation_id = types.StringAttribute{
    .name = "app.installation.id",
    .brief = "A unique identifier representing the installation of an application on a specific device",
    .note = "Its value SHOULD persist across launches of the same application installation, including through application upgrades. It SHOULD change if the application is uninstalled or if all applications of the vendor are uninstalled. Additionally, users might be able to reset this value (e.g. by clearing application data). If an app is installed multiple times on the same device (e.g. in different accounts on Android), each `app.installation.id` SHOULD have a different value. If multiple OpenTelemetry SDKs are used within the same application, they SHOULD use the same value for `app.installation.id`. Hardware IDs (e.g. serial number, IMEI, MAC address) MUST NOT be used as the `app.installation.id`.  For iOS, this value SHOULD be equal to the [vendor identifier](https://developer.apple.com/documentation/uikit/uidevice/identifierforvendor).  For Android, examples of `app.installation.id` implementations include:  - [Firebase Installation ID](https://firebase.google.com/docs/projects/manage-installations). - A globally unique UUID which is persisted across sessions in your application. - [App set ID](https://developer.android.com/identity/app-set-id). - [`Settings.getString(Settings.Secure.ANDROID_ID)`](https://developer.android.com/reference/android/provider/Settings.Secure#ANDROID_ID).  More information about Android identifier best practices can be found [here](https://developer.android.com/training/articles/user-data-ids).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The x (horizontal) coordinate of a screen coordinate, in screen pixels.
pub const app_screen_coordinate_x = types.IntAttribute{
    .name = "app.screen.coordinate.x",
    .brief = "The x (horizontal) coordinate of a screen coordinate, in screen pixels.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The y (vertical) component of a screen coordinate, in screen pixels.
pub const app_screen_coordinate_y = types.IntAttribute{
    .name = "app.screen.coordinate.y",
    .brief = "The y (vertical) component of a screen coordinate, in screen pixels.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// An identifier that uniquely differentiates this widget from other widgets in the same application.
pub const app_widget_id = types.StringAttribute{
    .name = "app.widget.id",
    .brief = "An identifier that uniquely differentiates this widget from other widgets in the same application.",
    .note = "A widget is an application component, typically an on-screen visual GUI element.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of an application widget.
pub const app_widget_name = types.StringAttribute{
    .name = "app.widget.name",
    .brief = "The name of an application widget.",
    .note = "A widget is an application component, typically an on-screen visual GUI element.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The provenance filename of the built attestation which directly relates to the build artifact filename. This filename SHOULD accompany the artifact at publish time. See the [SLSA Relationship](https://slsa.dev/spec/v1.0/distributing-provenance#relationship-between-artifacts-and-attestations) specification for more information.
pub const artifact_attestation_filename = types.StringAttribute{
    .name = "artifact.attestation.filename",
    .brief = "The provenance filename of the built attestation which directly relates to the build artifact filename. This filename SHOULD accompany the artifact at publish time. See the [SLSA Relationship](https://slsa.dev/spec/v1.0/distributing-provenance#relationship-between-artifacts-and-attestations) specification for more information.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full [hash value (see glossary)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf), of the built attestation. Some envelopes in the [software attestation space](https://github.com/in-toto/attestation/tree/main/spec) also refer to this as the **digest**.
pub const artifact_attestation_hash = types.StringAttribute{
    .name = "artifact.attestation.hash",
    .brief = "The full [hash value (see glossary)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf), of the built attestation. Some envelopes in the [software attestation space](https://github.com/in-toto/attestation/tree/main/spec) also refer to this as the **digest**.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The id of the build [software attestation](https://slsa.dev/attestation-model).
pub const artifact_attestation_id = types.StringAttribute{
    .name = "artifact.attestation.id",
    .brief = "The id of the build [software attestation](https://slsa.dev/attestation-model).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The human readable file name of the artifact, typically generated during build and release processes. Often includes the package name and version in the file name.
pub const artifact_filename = types.StringAttribute{
    .name = "artifact.filename",
    .brief = "The human readable file name of the artifact, typically generated during build and release processes. Often includes the package name and version in the file name.",
    .note = "This file name can also act as the [Package Name](https://slsa.dev/spec/v1.0/terminology#package-model) in cases where the package ecosystem maps accordingly. Additionally, the artifact [can be published](https://slsa.dev/spec/v1.0/terminology#software-supply-chain) for others, but that is not a guarantee.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full [hash value (see glossary)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf), often found in checksum.txt on a release of the artifact and used to verify package integrity.
pub const artifact_hash = types.StringAttribute{
    .name = "artifact.hash",
    .brief = "The full [hash value (see glossary)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf), often found in checksum.txt on a release of the artifact and used to verify package integrity.",
    .note = "The specific algorithm used to create the cryptographic hash value is not defined. In situations where an artifact has multiple cryptographic hashes, it is up to the implementer to choose which hash value to set here; this should be the most secure hash algorithm that is suitable for the situation and consistent with the corresponding attestation. The implementer can then provide the other hash values through an additional set of attribute extensions as they deem necessary.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [Package URL](https://github.com/package-url/purl-spec) of the [package artifact](https://slsa.dev/spec/v1.0/terminology#package-model) provides a standard way to identify and locate the packaged artifact.
pub const artifact_purl = types.StringAttribute{
    .name = "artifact.purl",
    .brief = "The [Package URL](https://github.com/package-url/purl-spec) of the [package artifact](https://slsa.dev/spec/v1.0/terminology#package-model) provides a standard way to identify and locate the packaged artifact.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version of the artifact.
pub const artifact_version = types.StringAttribute{
    .name = "artifact.version",
    .brief = "The version of the artifact.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const aspnetcore_diagnostics_exception_resultValue = enum {
    handled,
    unhandled,
    skipped,
    aborted,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .handled => "handled",
            .unhandled => "unhandled",
            .skipped => "skipped",
            .aborted => "aborted",
        };
    }
};

/// ASP.NET Core exception middleware handling result
pub const aspnetcore_diagnostics_exception_result = types.EnumAttribute(aspnetcore_diagnostics_exception_resultValue){
    .name = "aspnetcore.diagnostics.exception.result",
    .brief = "ASP.NET Core exception middleware handling result",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Full type name of the [`IExceptionHandler`](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.diagnostics.iexceptionhandler) implementation that handled the exception.
pub const aspnetcore_diagnostics_handler_type = types.StringAttribute{
    .name = "aspnetcore.diagnostics.handler.type",
    .brief = "Full type name of the [`IExceptionHandler`](https://learn.microsoft.com/dotnet/api/microsoft.aspnetcore.diagnostics.iexceptionhandler) implementation that handled the exception.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Rate limiting policy name.
pub const aspnetcore_rate_limiting_policy = types.StringAttribute{
    .name = "aspnetcore.rate_limiting.policy",
    .brief = "Rate limiting policy name.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const aspnetcore_rate_limiting_resultValue = enum {
    acquired,
    endpoint_limiter,
    global_limiter,
    request_canceled,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .acquired => "acquired",
            .endpoint_limiter => "endpoint_limiter",
            .global_limiter => "global_limiter",
            .request_canceled => "request_canceled",
        };
    }
};

/// Rate-limiting result, shows whether the lease was acquired or contains a rejection reason
pub const aspnetcore_rate_limiting_result = types.EnumAttribute(aspnetcore_rate_limiting_resultValue){
    .name = "aspnetcore.rate_limiting.result",
    .brief = "Rate-limiting result, shows whether the lease was acquired or contains a rejection reason",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Flag indicating if request was handled by the application pipeline.
pub const aspnetcore_request_is_unhandled = types.BooleanAttribute{
    .name = "aspnetcore.request.is_unhandled",
    .brief = "Flag indicating if request was handled by the application pipeline.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// A value that indicates whether the matched route is a fallback route.
pub const aspnetcore_routing_is_fallback = types.BooleanAttribute{
    .name = "aspnetcore.routing.is_fallback",
    .brief = "A value that indicates whether the matched route is a fallback route.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const aspnetcore_routing_match_statusValue = enum {
    success,
    failure,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .success => "success",
            .failure => "failure",
        };
    }
};

/// Match result - success or failure
pub const aspnetcore_routing_match_status = types.EnumAttribute(aspnetcore_routing_match_statusValue){
    .name = "aspnetcore.routing.match_status",
    .brief = "Match result - success or failure",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The unique identifier of the AWS Bedrock Guardrail. A [guardrail](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html) helps safeguard and prevent unwanted behavior from model responses or user messages.
pub const aws_bedrock_guardrail_id = types.StringAttribute{
    .name = "aws.bedrock.guardrail.id",
    .brief = "The unique identifier of the AWS Bedrock Guardrail. A [guardrail](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html) helps safeguard and prevent unwanted behavior from model responses or user messages.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier of the AWS Bedrock Knowledge base. A [knowledge base](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html) is a bank of information that can be queried by models to generate more relevant responses and augment prompts.
pub const aws_bedrock_knowledge_base_id = types.StringAttribute{
    .name = "aws.bedrock.knowledge_base.id",
    .brief = "The unique identifier of the AWS Bedrock Knowledge base. A [knowledge base](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html) is a bank of information that can be queried by models to generate more relevant responses and augment prompts.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The JSON-serialized value of each item in the `AttributeDefinitions` request field.
pub const aws_dynamodb_attribute_definitions = types.StringArrayAttribute{
    .name = "aws.dynamodb.attribute_definitions",
    .brief = "The JSON-serialized value of each item in the `AttributeDefinitions` request field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `AttributesToGet` request parameter.
pub const aws_dynamodb_attributes_to_get = types.StringArrayAttribute{
    .name = "aws.dynamodb.attributes_to_get",
    .brief = "The value of the `AttributesToGet` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `ConsistentRead` request parameter.
pub const aws_dynamodb_consistent_read = types.BooleanAttribute{
    .name = "aws.dynamodb.consistent_read",
    .brief = "The value of the `ConsistentRead` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The JSON-serialized value of each item in the `ConsumedCapacity` response field.
pub const aws_dynamodb_consumed_capacity = types.StringArrayAttribute{
    .name = "aws.dynamodb.consumed_capacity",
    .brief = "The JSON-serialized value of each item in the `ConsumedCapacity` response field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `Count` response parameter.
pub const aws_dynamodb_count = types.IntAttribute{
    .name = "aws.dynamodb.count",
    .brief = "The value of the `Count` response parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `ExclusiveStartTableName` request parameter.
pub const aws_dynamodb_exclusive_start_table = types.StringAttribute{
    .name = "aws.dynamodb.exclusive_start_table",
    .brief = "The value of the `ExclusiveStartTableName` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The JSON-serialized value of each item in the `GlobalSecondaryIndexUpdates` request field.
pub const aws_dynamodb_global_secondary_index_updates = types.StringArrayAttribute{
    .name = "aws.dynamodb.global_secondary_index_updates",
    .brief = "The JSON-serialized value of each item in the `GlobalSecondaryIndexUpdates` request field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The JSON-serialized value of each item of the `GlobalSecondaryIndexes` request field
pub const aws_dynamodb_global_secondary_indexes = types.StringArrayAttribute{
    .name = "aws.dynamodb.global_secondary_indexes",
    .brief = "The JSON-serialized value of each item of the `GlobalSecondaryIndexes` request field",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `IndexName` request parameter.
pub const aws_dynamodb_index_name = types.StringAttribute{
    .name = "aws.dynamodb.index_name",
    .brief = "The value of the `IndexName` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The JSON-serialized value of the `ItemCollectionMetrics` response field.
pub const aws_dynamodb_item_collection_metrics = types.StringAttribute{
    .name = "aws.dynamodb.item_collection_metrics",
    .brief = "The JSON-serialized value of the `ItemCollectionMetrics` response field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `Limit` request parameter.
pub const aws_dynamodb_limit = types.IntAttribute{
    .name = "aws.dynamodb.limit",
    .brief = "The value of the `Limit` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The JSON-serialized value of each item of the `LocalSecondaryIndexes` request field.
pub const aws_dynamodb_local_secondary_indexes = types.StringArrayAttribute{
    .name = "aws.dynamodb.local_secondary_indexes",
    .brief = "The JSON-serialized value of each item of the `LocalSecondaryIndexes` request field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `ProjectionExpression` request parameter.
pub const aws_dynamodb_projection = types.StringAttribute{
    .name = "aws.dynamodb.projection",
    .brief = "The value of the `ProjectionExpression` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `ProvisionedThroughput.ReadCapacityUnits` request parameter.
pub const aws_dynamodb_provisioned_read_capacity = types.DoubleAttribute{
    .name = "aws.dynamodb.provisioned_read_capacity",
    .brief = "The value of the `ProvisionedThroughput.ReadCapacityUnits` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `ProvisionedThroughput.WriteCapacityUnits` request parameter.
pub const aws_dynamodb_provisioned_write_capacity = types.DoubleAttribute{
    .name = "aws.dynamodb.provisioned_write_capacity",
    .brief = "The value of the `ProvisionedThroughput.WriteCapacityUnits` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `ScanIndexForward` request parameter.
pub const aws_dynamodb_scan_forward = types.BooleanAttribute{
    .name = "aws.dynamodb.scan_forward",
    .brief = "The value of the `ScanIndexForward` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `ScannedCount` response parameter.
pub const aws_dynamodb_scanned_count = types.IntAttribute{
    .name = "aws.dynamodb.scanned_count",
    .brief = "The value of the `ScannedCount` response parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `Segment` request parameter.
pub const aws_dynamodb_segment = types.IntAttribute{
    .name = "aws.dynamodb.segment",
    .brief = "The value of the `Segment` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `Select` request parameter.
pub const aws_dynamodb_select = types.StringAttribute{
    .name = "aws.dynamodb.select",
    .brief = "The value of the `Select` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The number of items in the `TableNames` response parameter.
pub const aws_dynamodb_table_count = types.IntAttribute{
    .name = "aws.dynamodb.table_count",
    .brief = "The number of items in the `TableNames` response parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The keys in the `RequestItems` object field.
pub const aws_dynamodb_table_names = types.StringArrayAttribute{
    .name = "aws.dynamodb.table_names",
    .brief = "The keys in the `RequestItems` object field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The value of the `TotalSegments` request parameter.
pub const aws_dynamodb_total_segments = types.IntAttribute{
    .name = "aws.dynamodb.total_segments",
    .brief = "The value of the `TotalSegments` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN of an [ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html).
pub const aws_ecs_cluster_arn = types.StringAttribute{
    .name = "aws.ecs.cluster.arn",
    .brief = "The ARN of an [ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The Amazon Resource Name (ARN) of an [ECS container instance](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_instances.html).
pub const aws_ecs_container_arn = types.StringAttribute{
    .name = "aws.ecs.container.arn",
    .brief = "The Amazon Resource Name (ARN) of an [ECS container instance](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_instances.html).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const aws_ecs_launchtypeValue = enum {
    ec2,
    fargate,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .ec2 => "ec2",
            .fargate => "fargate",
        };
    }
};

/// The [launch type](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html) for an ECS task.
pub const aws_ecs_launchtype = types.EnumAttribute(aws_ecs_launchtypeValue){
    .name = "aws.ecs.launchtype",
    .brief = "The [launch type](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html) for an ECS task.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN of a running [ECS task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-account-settings.html#ecs-resource-ids).
pub const aws_ecs_task_arn = types.StringAttribute{
    .name = "aws.ecs.task.arn",
    .brief = "The ARN of a running [ECS task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-account-settings.html#ecs-resource-ids).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The family name of the [ECS task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) used to create the ECS task.
pub const aws_ecs_task_family = types.StringAttribute{
    .name = "aws.ecs.task.family",
    .brief = "The family name of the [ECS task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) used to create the ECS task.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ID of a running ECS task. The ID MUST be extracted from `task.arn`.
pub const aws_ecs_task_id = types.StringAttribute{
    .name = "aws.ecs.task.id",
    .brief = "The ID of a running ECS task. The ID MUST be extracted from `task.arn`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The revision for the task definition used to create the ECS task.
pub const aws_ecs_task_revision = types.StringAttribute{
    .name = "aws.ecs.task.revision",
    .brief = "The revision for the task definition used to create the ECS task.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN of an EKS cluster.
pub const aws_eks_cluster_arn = types.StringAttribute{
    .name = "aws.eks.cluster.arn",
    .brief = "The ARN of an EKS cluster.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The AWS extended request ID as returned in the response header `x-amz-id-2`.
pub const aws_extended_request_id = types.StringAttribute{
    .name = "aws.extended_request_id",
    .brief = "The AWS extended request ID as returned in the response header `x-amz-id-2`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the AWS Kinesis [stream](https://docs.aws.amazon.com/streams/latest/dev/introduction.html) the request refers to. Corresponds to the `--stream-name` parameter of the Kinesis [describe-stream](https://docs.aws.amazon.com/cli/latest/reference/kinesis/describe-stream.html) operation.
pub const aws_kinesis_stream_name = types.StringAttribute{
    .name = "aws.kinesis.stream_name",
    .brief = "The name of the AWS Kinesis [stream](https://docs.aws.amazon.com/streams/latest/dev/introduction.html) the request refers to. Corresponds to the `--stream-name` parameter of the Kinesis [describe-stream](https://docs.aws.amazon.com/cli/latest/reference/kinesis/describe-stream.html) operation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full invoked ARN as provided on the `Context` passed to the function (`Lambda-Runtime-Invoked-Function-Arn` header on the `/runtime/invocation/next` applicable).
pub const aws_lambda_invoked_arn = types.StringAttribute{
    .name = "aws.lambda.invoked_arn",
    .brief = "The full invoked ARN as provided on the `Context` passed to the function (`Lambda-Runtime-Invoked-Function-Arn` header on the `/runtime/invocation/next` applicable).",
    .note = "This may be different from `cloud.resource_id` if an alias is involved.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UUID of the [AWS Lambda EvenSource Mapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html). An event source is mapped to a lambda function. It's contents are read by Lambda and used to trigger a function. This isn't available in the lambda execution context or the lambda runtime environtment. This is going to be populated by the AWS SDK for each language when that UUID is present. Some of these operations are Create/Delete/Get/List/Update EventSourceMapping.
pub const aws_lambda_resource_mapping_id = types.StringAttribute{
    .name = "aws.lambda.resource_mapping.id",
    .brief = "The UUID of the [AWS Lambda EvenSource Mapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html). An event source is mapped to a lambda function. It's contents are read by Lambda and used to trigger a function. This isn't available in the lambda execution context or the lambda runtime environtment. This is going to be populated by the AWS SDK for each language when that UUID is present. Some of these operations are Create/Delete/Get/List/Update EventSourceMapping.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The Amazon Resource Name(s) (ARN) of the AWS log group(s).
pub const aws_log_group_arns = types.StringArrayAttribute{
    .name = "aws.log.group.arns",
    .brief = "The Amazon Resource Name(s) (ARN) of the AWS log group(s).",
    .note = "See the [log group ARN format documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/iam-access-control-overview-cwl.html#CWL_ARN_Format).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name(s) of the AWS log group(s) an application is writing to.
pub const aws_log_group_names = types.StringArrayAttribute{
    .name = "aws.log.group.names",
    .brief = "The name(s) of the AWS log group(s) an application is writing to.",
    .note = "Multiple log groups must be supported for cases like multi-container applications, where a single application has sidecar containers, and each write to their own log group.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN(s) of the AWS log stream(s).
pub const aws_log_stream_arns = types.StringArrayAttribute{
    .name = "aws.log.stream.arns",
    .brief = "The ARN(s) of the AWS log stream(s).",
    .note = "See the [log stream ARN format documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/iam-access-control-overview-cwl.html#CWL_ARN_Format). One log group can contain several log streams, so these ARNs necessarily identify both a log group and a log stream.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name(s) of the AWS log stream(s) an application is writing to.
pub const aws_log_stream_names = types.StringArrayAttribute{
    .name = "aws.log.stream.names",
    .brief = "The name(s) of the AWS log stream(s) an application is writing to.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The AWS request ID as returned in the response headers `x-amzn-requestid`, `x-amzn-request-id` or `x-amz-request-id`.
pub const aws_request_id = types.StringAttribute{
    .name = "aws.request_id",
    .brief = "The AWS request ID as returned in the response headers `x-amzn-requestid`, `x-amzn-request-id` or `x-amz-request-id`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The S3 bucket name the request refers to. Corresponds to the `--bucket` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.
pub const aws_s3_bucket = types.StringAttribute{
    .name = "aws.s3.bucket",
    .brief = "The S3 bucket name the request refers to. Corresponds to the `--bucket` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.",
    .note = "The `bucket` attribute is applicable to all S3 operations that reference a bucket, i.e. that require the bucket name as a mandatory parameter. This applies to almost all S3 operations except `list-buckets`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The source object (in the form `bucket`/`key`) for the copy operation.
pub const aws_s3_copy_source = types.StringAttribute{
    .name = "aws.s3.copy_source",
    .brief = "The source object (in the form `bucket`/`key`) for the copy operation.",
    .note = "The `copy_source` attribute applies to S3 copy operations and corresponds to the `--copy-source` parameter of the [copy-object operation within the S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/copy-object.html). This applies in particular to the following operations:  - [copy-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/copy-object.html) - [upload-part-copy](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part-copy.html)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The delete request container that specifies the objects to be deleted.
pub const aws_s3_delete = types.StringAttribute{
    .name = "aws.s3.delete",
    .brief = "The delete request container that specifies the objects to be deleted.",
    .note = "The `delete` attribute is only applicable to the [delete-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/delete-object.html) operation. The `delete` attribute corresponds to the `--delete` parameter of the [delete-objects operation within the S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/delete-objects.html).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The S3 object key the request refers to. Corresponds to the `--key` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.
pub const aws_s3_key = types.StringAttribute{
    .name = "aws.s3.key",
    .brief = "The S3 object key the request refers to. Corresponds to the `--key` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.",
    .note = "The `key` attribute is applicable to all object-related S3 operations, i.e. that require the object key as a mandatory parameter. This applies in particular to the following operations:  - [copy-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/copy-object.html) - [delete-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/delete-object.html) - [get-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/get-object.html) - [head-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/head-object.html) - [put-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/put-object.html) - [restore-object](https://docs.aws.amazon.com/cli/latest/reference/s3api/restore-object.html) - [select-object-content](https://docs.aws.amazon.com/cli/latest/reference/s3api/select-object-content.html) - [abort-multipart-upload](https://docs.aws.amazon.com/cli/latest/reference/s3api/abort-multipart-upload.html) - [complete-multipart-upload](https://docs.aws.amazon.com/cli/latest/reference/s3api/complete-multipart-upload.html) - [create-multipart-upload](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-multipart-upload.html) - [list-parts](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-parts.html) - [upload-part](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part.html) - [upload-part-copy](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part-copy.html)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The part number of the part being uploaded in a multipart-upload operation. This is a positive integer between 1 and 10,000.
pub const aws_s3_part_number = types.IntAttribute{
    .name = "aws.s3.part_number",
    .brief = "The part number of the part being uploaded in a multipart-upload operation. This is a positive integer between 1 and 10,000.",
    .note = "The `part_number` attribute is only applicable to the [upload-part](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part.html) and [upload-part-copy](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part-copy.html) operations. The `part_number` attribute corresponds to the `--part-number` parameter of the [upload-part operation within the S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part.html).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Upload ID that identifies the multipart upload.
pub const aws_s3_upload_id = types.StringAttribute{
    .name = "aws.s3.upload_id",
    .brief = "Upload ID that identifies the multipart upload.",
    .note = "The `upload_id` attribute applies to S3 multipart-upload operations and corresponds to the `--upload-id` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) multipart operations. This applies in particular to the following operations:  - [abort-multipart-upload](https://docs.aws.amazon.com/cli/latest/reference/s3api/abort-multipart-upload.html) - [complete-multipart-upload](https://docs.aws.amazon.com/cli/latest/reference/s3api/complete-multipart-upload.html) - [list-parts](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-parts.html) - [upload-part](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part.html) - [upload-part-copy](https://docs.aws.amazon.com/cli/latest/reference/s3api/upload-part-copy.html)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN of the Secret stored in the Secrets Mangger
pub const aws_secretsmanager_secret_arn = types.StringAttribute{
    .name = "aws.secretsmanager.secret.arn",
    .brief = "The ARN of the Secret stored in the Secrets Mangger",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN of the AWS SNS Topic. An Amazon SNS [topic](https://docs.aws.amazon.com/sns/latest/dg/sns-create-topic.html) is a logical access point that acts as a communication channel.
pub const aws_sns_topic_arn = types.StringAttribute{
    .name = "aws.sns.topic.arn",
    .brief = "The ARN of the AWS SNS Topic. An Amazon SNS [topic](https://docs.aws.amazon.com/sns/latest/dg/sns-create-topic.html) is a logical access point that acts as a communication channel.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The URL of the AWS SQS Queue. It's a unique identifier for a queue in Amazon Simple Queue Service (SQS) and is used to access the queue and perform actions on it.
pub const aws_sqs_queue_url = types.StringAttribute{
    .name = "aws.sqs.queue.url",
    .brief = "The URL of the AWS SQS Queue. It's a unique identifier for a queue in Amazon Simple Queue Service (SQS) and is used to access the queue and perform actions on it.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN of the AWS Step Functions Activity.
pub const aws_step_functions_activity_arn = types.StringAttribute{
    .name = "aws.step_functions.activity.arn",
    .brief = "The ARN of the AWS Step Functions Activity.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ARN of the AWS Step Functions State Machine.
pub const aws_step_functions_state_machine_arn = types.StringAttribute{
    .name = "aws.step_functions.state_machine.arn",
    .brief = "The ARN of the AWS Step Functions State Machine.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `azure.resource_provider.namespace` instead.
pub const az_namespace = types.StringAttribute{
    .name = "az.namespace",
    .brief = "Deprecated, use `azure.resource_provider.namespace` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `azure.service.request.id` instead.
pub const az_service_request_id = types.StringAttribute{
    .name = "az.service_request_id",
    .brief = "Deprecated, use `azure.service.request.id` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier of the client instance.
pub const azure_client_id = types.StringAttribute{
    .name = "azure.client.id",
    .brief = "The unique identifier of the client instance.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const azure_cosmosdb_connection_modeValue = enum {
    gateway,
    direct,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .gateway => "gateway",
            .direct => "direct",
        };
    }
};

/// Cosmos client connection mode.
pub const azure_cosmosdb_connection_mode = types.EnumAttribute(azure_cosmosdb_connection_modeValue){
    .name = "azure.cosmosdb.connection.mode",
    .brief = "Cosmos client connection mode.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const azure_cosmosdb_consistency_levelValue = enum {
    strong,
    bounded_staleness,
    session,
    eventual,
    consistent_prefix,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .strong => "Strong",
            .bounded_staleness => "BoundedStaleness",
            .session => "Session",
            .eventual => "Eventual",
            .consistent_prefix => "ConsistentPrefix",
        };
    }
};

/// Account or request [consistency level](https://learn.microsoft.com/azure/cosmos-db/consistency-levels).
pub const azure_cosmosdb_consistency_level = types.EnumAttribute(azure_cosmosdb_consistency_levelValue){
    .name = "azure.cosmosdb.consistency.level",
    .brief = "Account or request [consistency level](https://learn.microsoft.com/azure/cosmos-db/consistency-levels).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// List of regions contacted during operation in the order that they were contacted. If there is more than one region listed, it indicates that the operation was performed on multiple regions i.e. cross-regional call.
pub const azure_cosmosdb_operation_contacted_regions = types.StringArrayAttribute{
    .name = "azure.cosmosdb.operation.contacted_regions",
    .brief = "List of regions contacted during operation in the order that they were contacted. If there is more than one region listed, it indicates that the operation was performed on multiple regions i.e. cross-regional call.",
    .note = "Region name matches the format of `displayName` in [Azure Location API](https://learn.microsoft.com/rest/api/subscription/subscriptions/list-locations?view=rest-subscription-2021-10-01&tabs=HTTP#location)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The number of request units consumed by the operation.
pub const azure_cosmosdb_operation_request_charge = types.DoubleAttribute{
    .name = "azure.cosmosdb.operation.request_charge",
    .brief = "The number of request units consumed by the operation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Request payload size in bytes.
pub const azure_cosmosdb_request_body_size = types.IntAttribute{
    .name = "azure.cosmosdb.request.body.size",
    .brief = "Request payload size in bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Cosmos DB sub status code.
pub const azure_cosmosdb_response_sub_status_code = types.IntAttribute{
    .name = "azure.cosmosdb.response.sub_status_code",
    .brief = "Cosmos DB sub status code.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// [Azure Resource Provider Namespace](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers) as recognized by the client.
pub const azure_resource_provider_namespace = types.StringAttribute{
    .name = "azure.resource_provider.namespace",
    .brief = "[Azure Resource Provider Namespace](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers) as recognized by the client.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier of the service request. It's generated by the Azure service and returned with the response.
pub const azure_service_request_id = types.StringAttribute{
    .name = "azure.service.request.id",
    .brief = "The unique identifier of the service request. It's generated by the Azure service and returned with the response.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Array of brand name and version separated by a space
pub const browser_brands = types.StringArrayAttribute{
    .name = "browser.brands",
    .brief = "Array of brand name and version separated by a space",
    .note = "This value is intended to be taken from the [UA client hints API](https://wicg.github.io/ua-client-hints/#interface) (`navigator.userAgentData.brands`).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Preferred language of the user using the browser
pub const browser_language = types.StringAttribute{
    .name = "browser.language",
    .brief = "Preferred language of the user using the browser",
    .note = "This value is intended to be taken from the Navigator API `navigator.language`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A boolean that is true if the browser is running on a mobile device
pub const browser_mobile = types.BooleanAttribute{
    .name = "browser.mobile",
    .brief = "A boolean that is true if the browser is running on a mobile device",
    .note = "This value is intended to be taken from the [UA client hints API](https://wicg.github.io/ua-client-hints/#interface) (`navigator.userAgentData.mobile`). If unavailable, this attribute SHOULD be left unset.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The platform on which the browser is running
pub const browser_platform = types.StringAttribute{
    .name = "browser.platform",
    .brief = "The platform on which the browser is running",
    .note = "This value is intended to be taken from the [UA client hints API](https://wicg.github.io/ua-client-hints/#interface) (`navigator.userAgentData.platform`). If unavailable, the legacy `navigator.platform` API SHOULD NOT be used instead and this attribute SHOULD be left unset in order for the values to be consistent. The list of possible values is defined in the [W3C User-Agent Client Hints specification](https://wicg.github.io/ua-client-hints/#sec-ch-ua-platform). Note that some (but not all) of these values can overlap with values in the [`os.type` and `os.name` attributes](./os.md). However, for consistency, the values in the `browser.platform` attribute should capture the exact value that the user agent provides.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cassandra_consistency_levelValue = enum {
    all,
    each_quorum,
    quorum,
    local_quorum,
    one,
    two,
    three,
    local_one,
    any,
    serial,
    local_serial,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .all => "all",
            .each_quorum => "each_quorum",
            .quorum => "quorum",
            .local_quorum => "local_quorum",
            .one => "one",
            .two => "two",
            .three => "three",
            .local_one => "local_one",
            .any => "any",
            .serial => "serial",
            .local_serial => "local_serial",
        };
    }
};

/// The consistency level of the query. Based on consistency values from [CQL](https://docs.datastax.com/en/cassandra-oss/3.0/cassandra/dml/dmlConfigConsistency.html).
pub const cassandra_consistency_level = types.EnumAttribute(cassandra_consistency_levelValue){
    .name = "cassandra.consistency.level",
    .brief = "The consistency level of the query. Based on consistency values from [CQL](https://docs.datastax.com/en/cassandra-oss/3.0/cassandra/dml/dmlConfigConsistency.html).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The data center of the coordinating node for a query.
pub const cassandra_coordinator_dc = types.StringAttribute{
    .name = "cassandra.coordinator.dc",
    .brief = "The data center of the coordinating node for a query.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ID of the coordinating node for a query.
pub const cassandra_coordinator_id = types.StringAttribute{
    .name = "cassandra.coordinator.id",
    .brief = "The ID of the coordinating node for a query.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The fetch size used for paging, i.e. how many rows will be returned at once.
pub const cassandra_page_size = types.IntAttribute{
    .name = "cassandra.page.size",
    .brief = "The fetch size used for paging, i.e. how many rows will be returned at once.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Whether or not the query is idempotent.
pub const cassandra_query_idempotent = types.BooleanAttribute{
    .name = "cassandra.query.idempotent",
    .brief = "Whether or not the query is idempotent.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The number of times a query was speculatively executed. Not set or `0` if the query was not executed speculatively.
pub const cassandra_speculative_execution_count = types.IntAttribute{
    .name = "cassandra.speculative_execution.count",
    .brief = "The number of times a query was speculatively executed. Not set or `0` if the query was not executed speculatively.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cicd_pipeline_action_nameValue = enum {
    build,
    run,
    sync,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .build => "BUILD",
            .run => "RUN",
            .sync => "SYNC",
        };
    }
};

/// The kind of action a pipeline run is performing.
pub const cicd_pipeline_action_name = types.EnumAttribute(cicd_pipeline_action_nameValue){
    .name = "cicd.pipeline.action.name",
    .brief = "The kind of action a pipeline run is performing.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The human readable name of the pipeline within a CI/CD system.
pub const cicd_pipeline_name = types.StringAttribute{
    .name = "cicd.pipeline.name",
    .brief = "The human readable name of the pipeline within a CI/CD system.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cicd_pipeline_resultValue = enum {
    success,
    failure,
    @"error",
    timeout,
    cancellation,
    skip,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .success => "success",
            .failure => "failure",
            .@"error" => "error",
            .timeout => "timeout",
            .cancellation => "cancellation",
            .skip => "skip",
        };
    }
};

/// The result of a pipeline run.
pub const cicd_pipeline_result = types.EnumAttribute(cicd_pipeline_resultValue){
    .name = "cicd.pipeline.result",
    .brief = "The result of a pipeline run.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier of a pipeline run within a CI/CD system.
pub const cicd_pipeline_run_id = types.StringAttribute{
    .name = "cicd.pipeline.run.id",
    .brief = "The unique identifier of a pipeline run within a CI/CD system.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cicd_pipeline_run_stateValue = enum {
    pending,
    executing,
    finalizing,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .pending => "pending",
            .executing => "executing",
            .finalizing => "finalizing",
        };
    }
};

/// The pipeline run goes through these states during its lifecycle.
pub const cicd_pipeline_run_state = types.EnumAttribute(cicd_pipeline_run_stateValue){
    .name = "cicd.pipeline.run.state",
    .brief = "The pipeline run goes through these states during its lifecycle.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [URL](https://wikipedia.org/wiki/URL) of the pipeline run, providing the complete address in order to locate and identify the pipeline run.
pub const cicd_pipeline_run_url_full = types.StringAttribute{
    .name = "cicd.pipeline.run.url.full",
    .brief = "The [URL](https://wikipedia.org/wiki/URL) of the pipeline run, providing the complete address in order to locate and identify the pipeline run.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The human readable name of a task within a pipeline. Task here most closely aligns with a [computing process](https://wikipedia.org/wiki/Pipeline_(computing)) in a pipeline. Other terms for tasks include commands, steps, and procedures.
pub const cicd_pipeline_task_name = types.StringAttribute{
    .name = "cicd.pipeline.task.name",
    .brief = "The human readable name of a task within a pipeline. Task here most closely aligns with a [computing process](https://wikipedia.org/wiki/Pipeline_(computing)) in a pipeline. Other terms for tasks include commands, steps, and procedures.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier of a task run within a pipeline.
pub const cicd_pipeline_task_run_id = types.StringAttribute{
    .name = "cicd.pipeline.task.run.id",
    .brief = "The unique identifier of a task run within a pipeline.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cicd_pipeline_task_run_resultValue = enum {
    success,
    failure,
    @"error",
    timeout,
    cancellation,
    skip,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .success => "success",
            .failure => "failure",
            .@"error" => "error",
            .timeout => "timeout",
            .cancellation => "cancellation",
            .skip => "skip",
        };
    }
};

/// The result of a task run.
pub const cicd_pipeline_task_run_result = types.EnumAttribute(cicd_pipeline_task_run_resultValue){
    .name = "cicd.pipeline.task.run.result",
    .brief = "The result of a task run.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [URL](https://wikipedia.org/wiki/URL) of the pipeline task run, providing the complete address in order to locate and identify the pipeline task run.
pub const cicd_pipeline_task_run_url_full = types.StringAttribute{
    .name = "cicd.pipeline.task.run.url.full",
    .brief = "The [URL](https://wikipedia.org/wiki/URL) of the pipeline task run, providing the complete address in order to locate and identify the pipeline task run.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cicd_pipeline_task_typeValue = enum {
    build,
    @"test",
    deploy,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .build => "build",
            .@"test" => "test",
            .deploy => "deploy",
        };
    }
};

/// The type of the task within a pipeline.
pub const cicd_pipeline_task_type = types.EnumAttribute(cicd_pipeline_task_typeValue){
    .name = "cicd.pipeline.task.type",
    .brief = "The type of the task within a pipeline.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of a component of the CICD system.
pub const cicd_system_component = types.StringAttribute{
    .name = "cicd.system.component",
    .brief = "The name of a component of the CICD system.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier of a worker within a CICD system.
pub const cicd_worker_id = types.StringAttribute{
    .name = "cicd.worker.id",
    .brief = "The unique identifier of a worker within a CICD system.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of a worker within a CICD system.
pub const cicd_worker_name = types.StringAttribute{
    .name = "cicd.worker.name",
    .brief = "The name of a worker within a CICD system.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cicd_worker_stateValue = enum {
    available,
    busy,
    offline,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .available => "available",
            .busy => "busy",
            .offline => "offline",
        };
    }
};

/// The state of a CICD worker / agent.
pub const cicd_worker_state = types.EnumAttribute(cicd_worker_stateValue){
    .name = "cicd.worker.state",
    .brief = "The state of a CICD worker / agent.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [URL](https://wikipedia.org/wiki/URL) of the worker, providing the complete address in order to locate and identify the worker.
pub const cicd_worker_url_full = types.StringAttribute{
    .name = "cicd.worker.url.full",
    .brief = "The [URL](https://wikipedia.org/wiki/URL) of the worker, providing the complete address in order to locate and identify the worker.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Client address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.
pub const client_address = types.StringAttribute{
    .name = "client.address",
    .brief = "Client address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.",
    .note = "When observed from the server side, and when communicating through an intermediary, `client.address` SHOULD represent the client address behind any intermediaries,  for example proxies, if it's available.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Client port number.
pub const client_port = types.IntAttribute{
    .name = "client.port",
    .brief = "Client port number.",
    .note = "When observed from the server side, and when communicating through an intermediary, `client.port` SHOULD represent the client port behind any intermediaries,  for example proxies, if it's available.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The cloud account ID the resource is assigned to.
pub const cloud_account_id = types.StringAttribute{
    .name = "cloud.account.id",
    .brief = "The cloud account ID the resource is assigned to.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Cloud regions often have multiple, isolated locations known as zones to increase availability. Availability zone represents the zone where the resource is running.
pub const cloud_availability_zone = types.StringAttribute{
    .name = "cloud.availability_zone",
    .brief = "Cloud regions often have multiple, isolated locations known as zones to increase availability. Availability zone represents the zone where the resource is running.",
    .note = "Availability zones are called \"zones\" on Alibaba Cloud and Google Cloud.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cloud_platformValue = enum {
    alibaba_cloud_ecs,
    alibaba_cloud_fc,
    alibaba_cloud_openshift,
    aws_ec2,
    aws_ecs,
    aws_eks,
    aws_lambda,
    aws_elastic_beanstalk,
    aws_app_runner,
    aws_openshift,
    azure_vm,
    azure_container_apps,
    azure_container_instances,
    azure_aks,
    azure_functions,
    azure_app_service,
    azure_openshift,
    gcp_bare_metal_solution,
    gcp_compute_engine,
    gcp_cloud_run,
    gcp_kubernetes_engine,
    gcp_cloud_functions,
    gcp_app_engine,
    gcp_openshift,
    ibm_cloud_openshift,
    oracle_cloud_compute,
    oracle_cloud_oke,
    tencent_cloud_cvm,
    tencent_cloud_eks,
    tencent_cloud_scf,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .alibaba_cloud_ecs => "alibaba_cloud_ecs",
            .alibaba_cloud_fc => "alibaba_cloud_fc",
            .alibaba_cloud_openshift => "alibaba_cloud_openshift",
            .aws_ec2 => "aws_ec2",
            .aws_ecs => "aws_ecs",
            .aws_eks => "aws_eks",
            .aws_lambda => "aws_lambda",
            .aws_elastic_beanstalk => "aws_elastic_beanstalk",
            .aws_app_runner => "aws_app_runner",
            .aws_openshift => "aws_openshift",
            .azure_vm => "azure.vm",
            .azure_container_apps => "azure.container_apps",
            .azure_container_instances => "azure.container_instances",
            .azure_aks => "azure.aks",
            .azure_functions => "azure.functions",
            .azure_app_service => "azure.app_service",
            .azure_openshift => "azure.openshift",
            .gcp_bare_metal_solution => "gcp_bare_metal_solution",
            .gcp_compute_engine => "gcp_compute_engine",
            .gcp_cloud_run => "gcp_cloud_run",
            .gcp_kubernetes_engine => "gcp_kubernetes_engine",
            .gcp_cloud_functions => "gcp_cloud_functions",
            .gcp_app_engine => "gcp_app_engine",
            .gcp_openshift => "gcp_openshift",
            .ibm_cloud_openshift => "ibm_cloud_openshift",
            .oracle_cloud_compute => "oracle_cloud_compute",
            .oracle_cloud_oke => "oracle_cloud_oke",
            .tencent_cloud_cvm => "tencent_cloud_cvm",
            .tencent_cloud_eks => "tencent_cloud_eks",
            .tencent_cloud_scf => "tencent_cloud_scf",
        };
    }
};

/// The cloud platform in use.
pub const cloud_platform = types.EnumAttribute(cloud_platformValue){
    .name = "cloud.platform",
    .brief = "The cloud platform in use.",
    .note = "The prefix of the service SHOULD match the one specified in `cloud.provider`.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cloud_providerValue = enum {
    alibaba_cloud,
    aws,
    azure,
    gcp,
    heroku,
    ibm_cloud,
    oracle_cloud,
    tencent_cloud,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .alibaba_cloud => "alibaba_cloud",
            .aws => "aws",
            .azure => "azure",
            .gcp => "gcp",
            .heroku => "heroku",
            .ibm_cloud => "ibm_cloud",
            .oracle_cloud => "oracle_cloud",
            .tencent_cloud => "tencent_cloud",
        };
    }
};

/// Name of the cloud provider.
pub const cloud_provider = types.EnumAttribute(cloud_providerValue){
    .name = "cloud.provider",
    .brief = "Name of the cloud provider.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The geographical region within a cloud provider. When associated with a resource, this attribute specifies the region where the resource operates. When calling services or APIs deployed on a cloud, this attribute identifies the region where the called destination is deployed.
pub const cloud_region = types.StringAttribute{
    .name = "cloud.region",
    .brief = "The geographical region within a cloud provider. When associated with a resource, this attribute specifies the region where the resource operates. When calling services or APIs deployed on a cloud, this attribute identifies the region where the called destination is deployed.",
    .note = "Refer to your provider's docs to see the available regions, for example [Alibaba Cloud regions](https://www.alibabacloud.com/help/doc-detail/40654.htm), [AWS regions](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/), [Azure regions](https://azure.microsoft.com/global-infrastructure/geographies/), [Google Cloud regions](https://cloud.google.com/about/locations), or [Tencent Cloud regions](https://www.tencentcloud.com/document/product/213/6091).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Cloud provider-specific native identifier of the monitored cloud resource (e.g. an [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) on AWS, a [fully qualified resource ID](https://learn.microsoft.com/rest/api/resources/resources/get-by-id) on Azure, a [full resource name](https://google.aip.dev/122#full-resource-names) on GCP)
pub const cloud_resource_id = types.StringAttribute{
    .name = "cloud.resource_id",
    .brief = "Cloud provider-specific native identifier of the monitored cloud resource (e.g. an [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) on AWS, a [fully qualified resource ID](https://learn.microsoft.com/rest/api/resources/resources/get-by-id) on Azure, a [full resource name](https://google.aip.dev/122#full-resource-names) on GCP)",
    .note = "On some cloud providers, it may not be possible to determine the full ID at startup, so it may be necessary to set `cloud.resource_id` as a span attribute instead.  The exact value to use for `cloud.resource_id` depends on the cloud provider. The following well-known definitions MUST be used if you set this attribute and they apply:  - **AWS Lambda:** The function [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html).   Take care not to use the \"invoked ARN\" directly but replace any   [alias suffix](https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html)   with the resolved function version, as the same runtime instance may be invocable with   multiple different aliases. - **GCP:** The [URI of the resource](https://cloud.google.com/iam/docs/full-resource-names) - **Azure:** The [Fully Qualified Resource ID](https://learn.microsoft.com/rest/api/resources/resources/get-by-id) of the invoked function,   *not* the function app, having the form   `/subscriptions/[SUBSCRIPTION_GUID]/resourceGroups/[RG]/providers/Microsoft.Web/sites/[FUNCAPP]/functions/[FUNC]`.   This means that a span attribute MUST be used, as an Azure function app can host multiple functions that would usually share   a TracerProvider.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [event_id](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#id) uniquely identifies the event.
pub const cloudevents_event_id = types.StringAttribute{
    .name = "cloudevents.event_id",
    .brief = "The [event_id](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#id) uniquely identifies the event.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [source](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#source-1) identifies the context in which an event happened.
pub const cloudevents_event_source = types.StringAttribute{
    .name = "cloudevents.event_source",
    .brief = "The [source](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#source-1) identifies the context in which an event happened.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [version of the CloudEvents specification](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#specversion) which the event uses.
pub const cloudevents_event_spec_version = types.StringAttribute{
    .name = "cloudevents.event_spec_version",
    .brief = "The [version of the CloudEvents specification](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#specversion) which the event uses.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [subject](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#subject) of the event in the context of the event producer (identified by source).
pub const cloudevents_event_subject = types.StringAttribute{
    .name = "cloudevents.event_subject",
    .brief = "The [subject](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#subject) of the event in the context of the event producer (identified by source).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [event_type](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type) contains a value describing the type of event related to the originating occurrence.
pub const cloudevents_event_type = types.StringAttribute{
    .name = "cloudevents.event_type",
    .brief = "The [event_type](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#type) contains a value describing the type of event related to the originating occurrence.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The guid of the application.
pub const cloudfoundry_app_id = types.StringAttribute{
    .name = "cloudfoundry.app.id",
    .brief = "The guid of the application.",
    .note = "Application instrumentation should use the value from environment variable `VCAP_APPLICATION.application_id`. This is the same value as reported by `cf app [app-name] --guid`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The index of the application instance. 0 when just one instance is active.
pub const cloudfoundry_app_instance_id = types.StringAttribute{
    .name = "cloudfoundry.app.instance.id",
    .brief = "The index of the application instance. 0 when just one instance is active.",
    .note = "CloudFoundry defines the `instance_id` in the [Loggregator v2 envelope](https://github.com/cloudfoundry/loggregator-api#v2-envelope). It is used for logs and metrics emitted by CloudFoundry. It is supposed to contain the application instance index for applications deployed on the runtime.  Application instrumentation should use the value from environment variable `CF_INSTANCE_INDEX`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the application.
pub const cloudfoundry_app_name = types.StringAttribute{
    .name = "cloudfoundry.app.name",
    .brief = "The name of the application.",
    .note = "Application instrumentation should use the value from environment variable `VCAP_APPLICATION.application_name`. This is the same value as reported by `cf apps`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The guid of the CloudFoundry org the application is running in.
pub const cloudfoundry_org_id = types.StringAttribute{
    .name = "cloudfoundry.org.id",
    .brief = "The guid of the CloudFoundry org the application is running in.",
    .note = "Application instrumentation should use the value from environment variable `VCAP_APPLICATION.org_id`. This is the same value as reported by `cf org [org-name] --guid`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the CloudFoundry organization the app is running in.
pub const cloudfoundry_org_name = types.StringAttribute{
    .name = "cloudfoundry.org.name",
    .brief = "The name of the CloudFoundry organization the app is running in.",
    .note = "Application instrumentation should use the value from environment variable `VCAP_APPLICATION.org_name`. This is the same value as reported by `cf orgs`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID identifying the process.
pub const cloudfoundry_process_id = types.StringAttribute{
    .name = "cloudfoundry.process.id",
    .brief = "The UID identifying the process.",
    .note = "Application instrumentation should use the value from environment variable `VCAP_APPLICATION.process_id`. It is supposed to be equal to `VCAP_APPLICATION.app_id` for applications deployed to the runtime. For system components, this could be the actual PID.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The type of process.
pub const cloudfoundry_process_type = types.StringAttribute{
    .name = "cloudfoundry.process.type",
    .brief = "The type of process.",
    .note = "CloudFoundry applications can consist of multiple jobs. Usually the main process will be of type `web`. There can be additional background tasks or side-cars with different process types.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The guid of the CloudFoundry space the application is running in.
pub const cloudfoundry_space_id = types.StringAttribute{
    .name = "cloudfoundry.space.id",
    .brief = "The guid of the CloudFoundry space the application is running in.",
    .note = "Application instrumentation should use the value from environment variable `VCAP_APPLICATION.space_id`. This is the same value as reported by `cf space [space-name] --guid`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the CloudFoundry space the application is running in.
pub const cloudfoundry_space_name = types.StringAttribute{
    .name = "cloudfoundry.space.name",
    .brief = "The name of the CloudFoundry space the application is running in.",
    .note = "Application instrumentation should use the value from environment variable `VCAP_APPLICATION.space_name`. This is the same value as reported by `cf spaces`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A guid or another name describing the event source.
pub const cloudfoundry_system_id = types.StringAttribute{
    .name = "cloudfoundry.system.id",
    .brief = "A guid or another name describing the event source.",
    .note = "CloudFoundry defines the `source_id` in the [Loggregator v2 envelope](https://github.com/cloudfoundry/loggregator-api#v2-envelope). It is used for logs and metrics emitted by CloudFoundry. It is supposed to contain the component name, e.g. \"gorouter\", for CloudFoundry components.  When system components are instrumented, values from the [Bosh spec](https://bosh.io/docs/jobs/#properties-spec) should be used. The `system.id` should be set to `spec.deployment/spec.name`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A guid describing the concrete instance of the event source.
pub const cloudfoundry_system_instance_id = types.StringAttribute{
    .name = "cloudfoundry.system.instance.id",
    .brief = "A guid describing the concrete instance of the event source.",
    .note = "CloudFoundry defines the `instance_id` in the [Loggregator v2 envelope](https://github.com/cloudfoundry/loggregator-api#v2-envelope). It is used for logs and metrics emitted by CloudFoundry. It is supposed to contain the vm id for CloudFoundry components.  When system components are instrumented, values from the [Bosh spec](https://bosh.io/docs/jobs/#properties-spec) should be used. The `system.instance.id` should be set to `spec.id`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `code.column.number`
pub const code_column = types.IntAttribute{
    .name = "code.column",
    .brief = "Deprecated, use `code.column.number`",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The column number in `code.file.path` best representing the operation. It SHOULD point within the code unit named in `code.function.name`. This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Line'. This constraint is imposed to prevent redundancy and maintain data integrity.
pub const code_column_number = types.IntAttribute{
    .name = "code.column.number",
    .brief = "The column number in `code.file.path` best representing the operation. It SHOULD point within the code unit named in `code.function.name`. This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Line'. This constraint is imposed to prevent redundancy and maintain data integrity.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The source code file name that identifies the code unit as uniquely as possible (preferably an absolute file path). This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Function'. This constraint is imposed to prevent redundancy and maintain data integrity.
pub const code_file_path = types.StringAttribute{
    .name = "code.file.path",
    .brief = "The source code file name that identifies the code unit as uniquely as possible (preferably an absolute file path). This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Function'. This constraint is imposed to prevent redundancy and maintain data integrity.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `code.file.path` instead
pub const code_filepath = types.StringAttribute{
    .name = "code.filepath",
    .brief = "Deprecated, use `code.file.path` instead",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `code.function.name` instead
pub const code_function = types.StringAttribute{
    .name = "code.function",
    .brief = "Deprecated, use `code.function.name` instead",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The method or function fully-qualified name without arguments. The value should fit the natural representation of the language runtime, which is also likely the same used within `code.stacktrace` attribute value. This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Function'. This constraint is imposed to prevent redundancy and maintain data integrity.
pub const code_function_name = types.StringAttribute{
    .name = "code.function.name",
    .brief = "The method or function fully-qualified name without arguments. The value should fit the natural representation of the language runtime, which is also likely the same used within `code.stacktrace` attribute value. This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Function'. This constraint is imposed to prevent redundancy and maintain data integrity.",
    .note = "Values and format depends on each language runtime, thus it is impossible to provide an exhaustive list of examples. The values are usually the same (or prefixes of) the ones found in native stack trace representation stored in `code.stacktrace` without information on arguments.  Examples:  * Java method: `com.example.MyHttpService.serveRequest` * Java anonymous class method: `com.mycompany.Main$1.myMethod` * Java lambda method: `com.mycompany.Main$$Lambda/0x0000748ae4149c00.myMethod` * PHP function: `GuzzleHttp\\Client::transfer` * Go function: `github.com/my/repo/pkg.foo.func5` * Elixir: `OpenTelemetry.Ctx.new` * Erlang: `opentelemetry_ctx:new` * Rust: `playground::my_module::my_cool_func` * C function: `fopen`",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The line number in `code.file.path` best representing the operation. It SHOULD point within the code unit named in `code.function.name`. This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Line'. This constraint is imposed to prevent redundancy and maintain data integrity.
pub const code_line_number = types.IntAttribute{
    .name = "code.line.number",
    .brief = "The line number in `code.file.path` best representing the operation. It SHOULD point within the code unit named in `code.function.name`. This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Line'. This constraint is imposed to prevent redundancy and maintain data integrity.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `code.line.number` instead
pub const code_lineno = types.IntAttribute{
    .name = "code.lineno",
    .brief = "Deprecated, use `code.line.number` instead",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, namespace is now included into `code.function.name`
pub const code_namespace = types.StringAttribute{
    .name = "code.namespace",
    .brief = "Deprecated, namespace is now included into `code.function.name`",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A stacktrace as a string in the natural representation for the language runtime. The representation is identical to [`exception.stacktrace`](/docs/exceptions/exceptions-spans.md#stacktrace-representation). This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Location'. This constraint is imposed to prevent redundancy and maintain data integrity.
pub const code_stacktrace = types.StringAttribute{
    .name = "code.stacktrace",
    .brief = "A stacktrace as a string in the natural representation for the language runtime. The representation is identical to [`exception.stacktrace`](/docs/exceptions/exceptions-spans.md#stacktrace-representation). This attribute MUST NOT be used on the Profile signal since the data is already captured in 'message Location'. This constraint is imposed to prevent redundancy and maintain data integrity.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The command used to run the container (i.e. the command name).
pub const container_command = types.StringAttribute{
    .name = "container.command",
    .brief = "The command used to run the container (i.e. the command name).",
    .note = "If using embedded credentials or sensitive data, it is recommended to remove them to prevent potential leakage.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// All the command arguments (including the command/executable itself) run by the container.
pub const container_command_args = types.StringArrayAttribute{
    .name = "container.command_args",
    .brief = "All the command arguments (including the command/executable itself) run by the container.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full command run by the container as a single string representing the full command.
pub const container_command_line = types.StringAttribute{
    .name = "container.command_line",
    .brief = "The full command run by the container as a single string representing the full command.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const container_cpu_stateValue = enum {
    user,
    system,
    kernel,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .user => "user",
            .system => "system",
            .kernel => "kernel",
        };
    }
};

/// Deprecated, use `cpu.mode` instead.
pub const container_cpu_state = types.EnumAttribute(container_cpu_stateValue){
    .name = "container.cpu.state",
    .brief = "Deprecated, use `cpu.mode` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the CSI ([Container Storage Interface](https://github.com/container-storage-interface/spec)) plugin used by the volume.
pub const container_csi_plugin_name = types.StringAttribute{
    .name = "container.csi.plugin.name",
    .brief = "The name of the CSI ([Container Storage Interface](https://github.com/container-storage-interface/spec)) plugin used by the volume.",
    .note = "This can sometimes be referred to as a \"driver\" in CSI implementations. This should represent the `name` field of the GetPluginInfo RPC.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique volume ID returned by the CSI ([Container Storage Interface](https://github.com/container-storage-interface/spec)) plugin.
pub const container_csi_volume_id = types.StringAttribute{
    .name = "container.csi.volume.id",
    .brief = "The unique volume ID returned by the CSI ([Container Storage Interface](https://github.com/container-storage-interface/spec)) plugin.",
    .note = "This can sometimes be referred to as a \"volume handle\" in CSI implementations. This should represent the `Volume.volume_id` field in CSI spec.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Container ID. Usually a UUID, as for example used to [identify Docker containers](https://docs.docker.com/engine/containers/run/#container-identification). The UUID might be abbreviated.
pub const container_id = types.StringAttribute{
    .name = "container.id",
    .brief = "Container ID. Usually a UUID, as for example used to [identify Docker containers](https://docs.docker.com/engine/containers/run/#container-identification). The UUID might be abbreviated.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Runtime specific image identifier. Usually a hash algorithm followed by a UUID.
pub const container_image_id = types.StringAttribute{
    .name = "container.image.id",
    .brief = "Runtime specific image identifier. Usually a hash algorithm followed by a UUID.",
    .note = "Docker defines a sha256 of the image id; `container.image.id` corresponds to the `Image` field from the Docker container inspect [API](https://docs.docker.com/engine/api/v1.43/#tag/Container/operation/ContainerInspect) endpoint. K8s defines a link to the container registry repository with digest `\"imageID\": \"registry.azurecr.io /namespace/service/dockerfile@sha256:bdeabd40c3a8a492eaf9e8e44d0ebbb84bac7ee25ac0cf8a7159d25f62555625\"`. The ID is assigned by the container runtime and can vary in different environments. Consider using `oci.manifest.digest` if it is important to identify the same image in different environments/runtimes.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the image the container was built on.
pub const container_image_name = types.StringAttribute{
    .name = "container.image.name",
    .brief = "Name of the image the container was built on.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Repo digests of the container image as provided by the container runtime.
pub const container_image_repo_digests = types.StringArrayAttribute{
    .name = "container.image.repo_digests",
    .brief = "Repo digests of the container image as provided by the container runtime.",
    .note = "[Docker](https://docs.docker.com/engine/api/v1.43/#tag/Image/operation/ImageInspect) and [CRI](https://github.com/kubernetes/cri-api/blob/c75ef5b473bbe2d0a4fc92f82235efd665ea8e9f/pkg/apis/runtime/v1/api.proto#L1237-L1238) report those under the `RepoDigests` field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Container image tags. An example can be found in [Docker Image Inspect](https://docs.docker.com/engine/api/v1.43/#tag/Image/operation/ImageInspect). Should be only the `<tag>` section of the full name for example from `registry.example.com/my-org/my-image:<tag>`.
pub const container_image_tags = types.StringArrayAttribute{
    .name = "container.image.tags",
    .brief = "Container image tags. An example can be found in [Docker Image Inspect](https://docs.docker.com/engine/api/v1.43/#tag/Image/operation/ImageInspect). Should be only the `<tag>` section of the full name for example from `registry.example.com/my-org/my-image:<tag>`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Container labels, ``key`` being the label name, the value being the label value.
pub const container_label = types.StringAttribute{
    .name = "container.label",
    .brief = "Container labels, ``key`` being the label name, the value being the label value.",
    .note = "For example, a docker container label `app` with value `nginx` SHOULD be recorded as the `container.label.app` attribute with value `\"nginx\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `container.label` instead.
pub const container_labels = types.StringAttribute{
    .name = "container.labels",
    .brief = "Deprecated, use `container.label` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Container name used by container runtime.
pub const container_name = types.StringAttribute{
    .name = "container.name",
    .brief = "Container name used by container runtime.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The container runtime managing this container.
pub const container_runtime = types.StringAttribute{
    .name = "container.runtime",
    .brief = "The container runtime managing this container.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The logical CPU number [0..n-1]
pub const cpu_logical_number = types.IntAttribute{
    .name = "cpu.logical_number",
    .brief = "The logical CPU number [0..n-1]",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cpu_modeValue = enum {
    user,
    system,
    nice,
    idle,
    iowait,
    interrupt,
    steal,
    kernel,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .user => "user",
            .system => "system",
            .nice => "nice",
            .idle => "idle",
            .iowait => "iowait",
            .interrupt => "interrupt",
            .steal => "steal",
            .kernel => "kernel",
        };
    }
};

/// The mode of the CPU
pub const cpu_mode = types.EnumAttribute(cpu_modeValue){
    .name = "cpu.mode",
    .brief = "The mode of the CPU",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const cpython_gc_generationValue = enum {
    generation_0,
    generation_1,
    generation_2,
    pub fn toInt(self: @This()) i64 {
        return switch (self) {
            .generation_0 => 0,
            .generation_1 => 1,
            .generation_2 => 2,
        };
    }
};

/// Value of the garbage collector collection generation.
pub const cpython_gc_generation = types.IntEnumAttribute(cpython_gc_generationValue){
    .name = "cpython.gc.generation",
    .brief = "Value of the garbage collector collection generation.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const db_cassandra_consistency_levelValue = enum {
    all,
    each_quorum,
    quorum,
    local_quorum,
    one,
    two,
    three,
    local_one,
    any,
    serial,
    local_serial,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .all => "all",
            .each_quorum => "each_quorum",
            .quorum => "quorum",
            .local_quorum => "local_quorum",
            .one => "one",
            .two => "two",
            .three => "three",
            .local_one => "local_one",
            .any => "any",
            .serial => "serial",
            .local_serial => "local_serial",
        };
    }
};

/// Deprecated, use `cassandra.consistency.level` instead.
pub const db_cassandra_consistency_level = types.EnumAttribute(db_cassandra_consistency_levelValue){
    .name = "db.cassandra.consistency_level",
    .brief = "Deprecated, use `cassandra.consistency.level` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `cassandra.coordinator.dc` instead.
pub const db_cassandra_coordinator_dc = types.StringAttribute{
    .name = "db.cassandra.coordinator.dc",
    .brief = "Deprecated, use `cassandra.coordinator.dc` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `cassandra.coordinator.id` instead.
pub const db_cassandra_coordinator_id = types.StringAttribute{
    .name = "db.cassandra.coordinator.id",
    .brief = "Deprecated, use `cassandra.coordinator.id` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `cassandra.query.idempotent` instead.
pub const db_cassandra_idempotence = types.BooleanAttribute{
    .name = "db.cassandra.idempotence",
    .brief = "Deprecated, use `cassandra.query.idempotent` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `cassandra.page.size` instead.
pub const db_cassandra_page_size = types.IntAttribute{
    .name = "db.cassandra.page_size",
    .brief = "Deprecated, use `cassandra.page.size` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `cassandra.speculative_execution.count` instead.
pub const db_cassandra_speculative_execution_count = types.IntAttribute{
    .name = "db.cassandra.speculative_execution_count",
    .brief = "Deprecated, use `cassandra.speculative_execution.count` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.collection.name` instead.
pub const db_cassandra_table = types.StringAttribute{
    .name = "db.cassandra.table",
    .brief = "Deprecated, use `db.collection.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the connection pool; unique within the instrumented application. In case the connection pool implementation doesn't provide a name, instrumentation SHOULD use a combination of parameters that would make the name unique, for example, combining attributes `server.address`, `server.port`, and `db.namespace`, formatted as `server.address:server.port/db.namespace`. Instrumentations that generate connection pool name following different patterns SHOULD document it.
pub const db_client_connection_pool_name = types.StringAttribute{
    .name = "db.client.connection.pool.name",
    .brief = "The name of the connection pool; unique within the instrumented application. In case the connection pool implementation doesn't provide a name, instrumentation SHOULD use a combination of parameters that would make the name unique, for example, combining attributes `server.address`, `server.port`, and `db.namespace`, formatted as `server.address:server.port/db.namespace`. Instrumentations that generate connection pool name following different patterns SHOULD document it.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const db_client_connection_stateValue = enum {
    idle,
    used,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .idle => "idle",
            .used => "used",
        };
    }
};

/// The state of a connection in the pool
pub const db_client_connection_state = types.EnumAttribute(db_client_connection_stateValue){
    .name = "db.client.connection.state",
    .brief = "The state of a connection in the pool",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.client.connection.pool.name` instead.
pub const db_client_connections_pool_name = types.StringAttribute{
    .name = "db.client.connections.pool.name",
    .brief = "Deprecated, use `db.client.connection.pool.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const db_client_connections_stateValue = enum {
    idle,
    used,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .idle => "idle",
            .used => "used",
        };
    }
};

/// Deprecated, use `db.client.connection.state` instead.
pub const db_client_connections_state = types.EnumAttribute(db_client_connections_stateValue){
    .name = "db.client.connections.state",
    .brief = "Deprecated, use `db.client.connection.state` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of a collection (table, container) within the database.
pub const db_collection_name = types.StringAttribute{
    .name = "db.collection.name",
    .brief = "The name of a collection (table, container) within the database.",
    .note = "It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.  The collection name SHOULD NOT be extracted from `db.query.text`, when the database system supports query text with multiple collections in non-batch operations.  For batch operations, if the individual operations are known to have the same collection name then that collection name SHOULD be used.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `server.address`, `server.port` attributes instead.
pub const db_connection_string = types.StringAttribute{
    .name = "db.connection_string",
    .brief = "Deprecated, use `server.address`, `server.port` attributes instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `azure.client.id` instead.
pub const db_cosmosdb_client_id = types.StringAttribute{
    .name = "db.cosmosdb.client_id",
    .brief = "Deprecated, use `azure.client.id` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const db_cosmosdb_connection_modeValue = enum {
    gateway,
    direct,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .gateway => "gateway",
            .direct => "direct",
        };
    }
};

/// Deprecated, use `azure.cosmosdb.connection.mode` instead.
pub const db_cosmosdb_connection_mode = types.EnumAttribute(db_cosmosdb_connection_modeValue){
    .name = "db.cosmosdb.connection_mode",
    .brief = "Deprecated, use `azure.cosmosdb.connection.mode` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const db_cosmosdb_consistency_levelValue = enum {
    strong,
    bounded_staleness,
    session,
    eventual,
    consistent_prefix,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .strong => "Strong",
            .bounded_staleness => "BoundedStaleness",
            .session => "Session",
            .eventual => "Eventual",
            .consistent_prefix => "ConsistentPrefix",
        };
    }
};

/// Deprecated, use `cosmosdb.consistency.level` instead.
pub const db_cosmosdb_consistency_level = types.EnumAttribute(db_cosmosdb_consistency_levelValue){
    .name = "db.cosmosdb.consistency_level",
    .brief = "Deprecated, use `cosmosdb.consistency.level` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.collection.name` instead.
pub const db_cosmosdb_container = types.StringAttribute{
    .name = "db.cosmosdb.container",
    .brief = "Deprecated, use `db.collection.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const db_cosmosdb_operation_typeValue = enum {
    batch,
    create,
    delete,
    execute,
    execute_javascript,
    invalid,
    head,
    head_feed,
    patch,
    query,
    query_plan,
    read,
    read_feed,
    replace,
    upsert,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .batch => "batch",
            .create => "create",
            .delete => "delete",
            .execute => "execute",
            .execute_javascript => "execute_javascript",
            .invalid => "invalid",
            .head => "head",
            .head_feed => "head_feed",
            .patch => "patch",
            .query => "query",
            .query_plan => "query_plan",
            .read => "read",
            .read_feed => "read_feed",
            .replace => "replace",
            .upsert => "upsert",
        };
    }
};

/// Deprecated, no replacement at this time.
pub const db_cosmosdb_operation_type = types.EnumAttribute(db_cosmosdb_operation_typeValue){
    .name = "db.cosmosdb.operation_type",
    .brief = "Deprecated, no replacement at this time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `azure.cosmosdb.operation.contacted_regions` instead.
pub const db_cosmosdb_regions_contacted = types.StringArrayAttribute{
    .name = "db.cosmosdb.regions_contacted",
    .brief = "Deprecated, use `azure.cosmosdb.operation.contacted_regions` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `azure.cosmosdb.operation.request_charge` instead.
pub const db_cosmosdb_request_charge = types.DoubleAttribute{
    .name = "db.cosmosdb.request_charge",
    .brief = "Deprecated, use `azure.cosmosdb.operation.request_charge` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `azure.cosmosdb.request.body.size` instead.
pub const db_cosmosdb_request_content_length = types.IntAttribute{
    .name = "db.cosmosdb.request_content_length",
    .brief = "Deprecated, use `azure.cosmosdb.request.body.size` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.response.status_code` instead.
pub const db_cosmosdb_status_code = types.IntAttribute{
    .name = "db.cosmosdb.status_code",
    .brief = "Deprecated, use `db.response.status_code` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `azure.cosmosdb.response.sub_status_code` instead.
pub const db_cosmosdb_sub_status_code = types.IntAttribute{
    .name = "db.cosmosdb.sub_status_code",
    .brief = "Deprecated, use `azure.cosmosdb.response.sub_status_code` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.namespace` instead.
pub const db_elasticsearch_cluster_name = types.StringAttribute{
    .name = "db.elasticsearch.cluster.name",
    .brief = "Deprecated, use `db.namespace` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `elasticsearch.node.name` instead.
pub const db_elasticsearch_node_name = types.StringAttribute{
    .name = "db.elasticsearch.node.name",
    .brief = "Deprecated, use `elasticsearch.node.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.operation.parameter` instead.
pub const db_elasticsearch_path_parts = types.StringAttribute{
    .name = "db.elasticsearch.path_parts",
    .brief = "Deprecated, use `db.operation.parameter` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, no general replacement at this time. For Elasticsearch, use `db.elasticsearch.node.name` instead.
pub const db_instance_id = types.StringAttribute{
    .name = "db.instance.id",
    .brief = "Deprecated, no general replacement at this time. For Elasticsearch, use `db.elasticsearch.node.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Removed, no replacement at this time.
pub const db_jdbc_driver_classname = types.StringAttribute{
    .name = "db.jdbc.driver_classname",
    .brief = "Removed, no replacement at this time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.collection.name` instead.
pub const db_mongodb_collection = types.StringAttribute{
    .name = "db.mongodb.collection",
    .brief = "Deprecated, use `db.collection.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, SQL Server instance is now populated as a part of `db.namespace` attribute.
pub const db_mssql_instance_name = types.StringAttribute{
    .name = "db.mssql.instance_name",
    .brief = "Deprecated, SQL Server instance is now populated as a part of `db.namespace` attribute.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.namespace` instead.
pub const db_name = types.StringAttribute{
    .name = "db.name",
    .brief = "Deprecated, use `db.namespace` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the database, fully qualified within the server address and port.
pub const db_namespace = types.StringAttribute{
    .name = "db.namespace",
    .brief = "The name of the database, fully qualified within the server address and port.",
    .note = "If a database system has multiple namespace components, they SHOULD be concatenated from the most general to the most specific namespace component, using `|` as a separator between the components. Any missing components (and their associated separators) SHOULD be omitted. Semantic conventions for individual database systems SHOULD document what `db.namespace` means in the context of that system. It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.operation.name` instead.
pub const db_operation = types.StringAttribute{
    .name = "db.operation",
    .brief = "Deprecated, use `db.operation.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The number of queries included in a batch operation.
pub const db_operation_batch_size = types.IntAttribute{
    .name = "db.operation.batch.size",
    .brief = "The number of queries included in a batch operation.",
    .note = "Operations are only considered batches when they contain two or more operations, and so `db.operation.batch.size` SHOULD never be `1`.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The name of the operation or command being executed.
pub const db_operation_name = types.StringAttribute{
    .name = "db.operation.name",
    .brief = "The name of the operation or command being executed.",
    .note = "It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.  The operation name SHOULD NOT be extracted from `db.query.text`, when the database system supports query text with multiple operations in non-batch operations.  If spaces can occur in the operation name, multiple consecutive spaces SHOULD be normalized to a single space.  For batch operations, if the individual operations are known to have the same operation name then that operation name SHOULD be used prepended by `BATCH `, otherwise `db.operation.name` SHOULD be `BATCH` or some other database system specific term if more applicable.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// A database operation parameter, with ``key`` being the parameter name, and the attribute value being a string representation of the parameter value.
pub const db_operation_parameter = types.StringAttribute{
    .name = "db.operation.parameter",
    .brief = "A database operation parameter, with ``key`` being the parameter name, and the attribute value being a string representation of the parameter value.",
    .note = "For example, a client-side maximum number of rows to read from the database MAY be recorded as the `db.operation.parameter.max_rows` attribute.  `db.query.text` parameters SHOULD be captured using `db.query.parameter.[key]` instead of `db.operation.parameter.[key]`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A database query parameter, with ``key`` being the parameter name, and the attribute value being a string representation of the parameter value.
pub const db_query_parameter = types.StringAttribute{
    .name = "db.query.parameter",
    .brief = "A database query parameter, with ``key`` being the parameter name, and the attribute value being a string representation of the parameter value.",
    .note = "If a query parameter has no name and instead is referenced only by index, then `[key]` SHOULD be the 0-based index.  `db.query.parameter.[key]` SHOULD match up with the parameterized placeholders present in `db.query.text`.  `db.query.parameter.[key]` SHOULD NOT be captured on batch operations.  Examples:  - For a query `SELECT * FROM users where username =  %s` with the parameter `\"jdoe\"`,   the attribute `db.query.parameter.0` SHOULD be set to `\"jdoe\"`.  - For a query `\"SELECT * FROM users WHERE username = %(username)s;` with parameter   `username = \"jdoe\"`, the attribute `db.query.parameter.username` SHOULD be set to `\"jdoe\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Low cardinality summary of a database query.
pub const db_query_summary = types.StringAttribute{
    .name = "db.query.summary",
    .brief = "Low cardinality summary of a database query.",
    .note = "The query summary describes a class of database queries and is useful as a grouping key, especially when analyzing telemetry for database calls involving complex queries.  Summary may be available to the instrumentation through instrumentation hooks or other means. If it is not available, instrumentations that support query parsing SHOULD generate a summary following [Generating query summary](/docs/database/database-spans.md#generating-a-summary-of-the-query) section.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The database query being executed.
pub const db_query_text = types.StringAttribute{
    .name = "db.query.text",
    .brief = "The database query being executed.",
    .note = "For sanitization see [Sanitization of `db.query.text`](/docs/database/database-spans.md#sanitization-of-dbquerytext). For batch operations, if the individual operations are known to have the same query text then that query text SHOULD be used, otherwise all of the individual query texts SHOULD be concatenated with separator `; ` or some other database system specific separator if more applicable. Parameterized query text SHOULD NOT be sanitized. Even though parameterized query text can potentially have sensitive data, by using a parameterized query the user is giving a strong signal that any sensitive data will be passed as parameter values, and the benefit to observability of capturing the static part of the query text by default outweighs the risk.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.namespace` instead.
pub const db_redis_database_index = types.IntAttribute{
    .name = "db.redis.database_index",
    .brief = "Deprecated, use `db.namespace` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Number of rows returned by the operation.
pub const db_response_returned_rows = types.IntAttribute{
    .name = "db.response.returned_rows",
    .brief = "Number of rows returned by the operation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Database response status code.
pub const db_response_status_code = types.StringAttribute{
    .name = "db.response.status_code",
    .brief = "Database response status code.",
    .note = "The status code returned by the database. Usually it represents an error code, but may also represent partial success, warning, or differentiate between various types of successful outcomes. Semantic conventions for individual database systems SHOULD document what `db.response.status_code` means in the context of that system.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.collection.name` instead.
pub const db_sql_table = types.StringAttribute{
    .name = "db.sql.table",
    .brief = "Deprecated, use `db.collection.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The database statement being executed.
pub const db_statement = types.StringAttribute{
    .name = "db.statement",
    .brief = "The database statement being executed.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of a stored procedure within the database.
pub const db_stored_procedure_name = types.StringAttribute{
    .name = "db.stored_procedure.name",
    .brief = "The name of a stored procedure within the database.",
    .note = "It is RECOMMENDED to capture the value as provided by the application without attempting to do any case normalization.  For batch operations, if the individual operations are known to have the same stored procedure name then that stored procedure name SHOULD be used.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const db_systemValue = enum {
    other_sql,
    adabas,
    cache,
    intersystems_cache,
    cassandra,
    clickhouse,
    cloudscape,
    cockroachdb,
    coldfusion,
    cosmosdb,
    couchbase,
    couchdb,
    db2,
    derby,
    dynamodb,
    edb,
    elasticsearch,
    filemaker,
    firebird,
    firstsql,
    geode,
    h2,
    hanadb,
    hbase,
    hive,
    hsqldb,
    influxdb,
    informix,
    ingres,
    instantdb,
    interbase,
    mariadb,
    maxdb,
    memcached,
    mongodb,
    mssql,
    mssqlcompact,
    mysql,
    neo4j,
    netezza,
    opensearch,
    oracle,
    pervasive,
    pointbase,
    postgresql,
    progress,
    redis,
    redshift,
    spanner,
    sqlite,
    sybase,
    teradata,
    trino,
    vertica,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .other_sql => "other_sql",
            .adabas => "adabas",
            .cache => "cache",
            .intersystems_cache => "intersystems_cache",
            .cassandra => "cassandra",
            .clickhouse => "clickhouse",
            .cloudscape => "cloudscape",
            .cockroachdb => "cockroachdb",
            .coldfusion => "coldfusion",
            .cosmosdb => "cosmosdb",
            .couchbase => "couchbase",
            .couchdb => "couchdb",
            .db2 => "db2",
            .derby => "derby",
            .dynamodb => "dynamodb",
            .edb => "edb",
            .elasticsearch => "elasticsearch",
            .filemaker => "filemaker",
            .firebird => "firebird",
            .firstsql => "firstsql",
            .geode => "geode",
            .h2 => "h2",
            .hanadb => "hanadb",
            .hbase => "hbase",
            .hive => "hive",
            .hsqldb => "hsqldb",
            .influxdb => "influxdb",
            .informix => "informix",
            .ingres => "ingres",
            .instantdb => "instantdb",
            .interbase => "interbase",
            .mariadb => "mariadb",
            .maxdb => "maxdb",
            .memcached => "memcached",
            .mongodb => "mongodb",
            .mssql => "mssql",
            .mssqlcompact => "mssqlcompact",
            .mysql => "mysql",
            .neo4j => "neo4j",
            .netezza => "netezza",
            .opensearch => "opensearch",
            .oracle => "oracle",
            .pervasive => "pervasive",
            .pointbase => "pointbase",
            .postgresql => "postgresql",
            .progress => "progress",
            .redis => "redis",
            .redshift => "redshift",
            .spanner => "spanner",
            .sqlite => "sqlite",
            .sybase => "sybase",
            .teradata => "teradata",
            .trino => "trino",
            .vertica => "vertica",
        };
    }
};

/// Deprecated, use `db.system.name` instead.
pub const db_system = types.EnumAttribute(db_systemValue){
    .name = "db.system",
    .brief = "Deprecated, use `db.system.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const db_system_nameValue = enum {
    other_sql,
    softwareag_adabas,
    actian_ingres,
    aws_dynamodb,
    aws_redshift,
    azure_cosmosdb,
    intersystems_cache,
    cassandra,
    clickhouse,
    cockroachdb,
    couchbase,
    couchdb,
    derby,
    elasticsearch,
    firebirdsql,
    gcp_spanner,
    geode,
    h2database,
    hbase,
    hive,
    hsqldb,
    ibm_db2,
    ibm_informix,
    ibm_netezza,
    influxdb,
    instantdb,
    mariadb,
    memcached,
    mongodb,
    microsoft_sql_server,
    mysql,
    neo4j,
    opensearch,
    oracle_db,
    postgresql,
    redis,
    sap_hana,
    sap_maxdb,
    sqlite,
    teradata,
    trino,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .other_sql => "other_sql",
            .softwareag_adabas => "softwareag.adabas",
            .actian_ingres => "actian.ingres",
            .aws_dynamodb => "aws.dynamodb",
            .aws_redshift => "aws.redshift",
            .azure_cosmosdb => "azure.cosmosdb",
            .intersystems_cache => "intersystems.cache",
            .cassandra => "cassandra",
            .clickhouse => "clickhouse",
            .cockroachdb => "cockroachdb",
            .couchbase => "couchbase",
            .couchdb => "couchdb",
            .derby => "derby",
            .elasticsearch => "elasticsearch",
            .firebirdsql => "firebirdsql",
            .gcp_spanner => "gcp.spanner",
            .geode => "geode",
            .h2database => "h2database",
            .hbase => "hbase",
            .hive => "hive",
            .hsqldb => "hsqldb",
            .ibm_db2 => "ibm.db2",
            .ibm_informix => "ibm.informix",
            .ibm_netezza => "ibm.netezza",
            .influxdb => "influxdb",
            .instantdb => "instantdb",
            .mariadb => "mariadb",
            .memcached => "memcached",
            .mongodb => "mongodb",
            .microsoft_sql_server => "microsoft.sql_server",
            .mysql => "mysql",
            .neo4j => "neo4j",
            .opensearch => "opensearch",
            .oracle_db => "oracle.db",
            .postgresql => "postgresql",
            .redis => "redis",
            .sap_hana => "sap.hana",
            .sap_maxdb => "sap.maxdb",
            .sqlite => "sqlite",
            .teradata => "teradata",
            .trino => "trino",
        };
    }
};

/// The database management system (DBMS) product as identified by the client instrumentation.
pub const db_system_name = types.EnumAttribute(db_system_nameValue){
    .name = "db.system.name",
    .brief = "The database management system (DBMS) product as identified by the client instrumentation.",
    .note = "The actual DBMS may differ from the one identified by the client. For example, when using PostgreSQL client libraries to connect to a CockroachDB, the `db.system.name` is set to `postgresql` based on the instrumentation's best knowledge.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, no replacement at this time.
pub const db_user = types.StringAttribute{
    .name = "db.user",
    .brief = "Deprecated, no replacement at this time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// 'Deprecated, use `deployment.environment.name` instead.'
pub const deployment_environment = types.StringAttribute{
    .name = "deployment.environment",
    .brief = "'Deprecated, use `deployment.environment.name` instead.'",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the [deployment environment](https://wikipedia.org/wiki/Deployment_environment) (aka deployment tier).
pub const deployment_environment_name = types.StringAttribute{
    .name = "deployment.environment.name",
    .brief = "Name of the [deployment environment](https://wikipedia.org/wiki/Deployment_environment) (aka deployment tier).",
    .note = "`deployment.environment.name` does not affect the uniqueness constraints defined through the `service.namespace`, `service.name` and `service.instance.id` resource attributes. This implies that resources carrying the following attribute combinations MUST be considered to be identifying the same service:  - `service.name=frontend`, `deployment.environment.name=production` - `service.name=frontend`, `deployment.environment.name=staging`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The id of the deployment.
pub const deployment_id = types.StringAttribute{
    .name = "deployment.id",
    .brief = "The id of the deployment.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the deployment.
pub const deployment_name = types.StringAttribute{
    .name = "deployment.name",
    .brief = "The name of the deployment.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const deployment_statusValue = enum {
    failed,
    succeeded,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .failed => "failed",
            .succeeded => "succeeded",
        };
    }
};

/// The status of the deployment.
pub const deployment_status = types.EnumAttribute(deployment_statusValue){
    .name = "deployment.status",
    .brief = "The status of the deployment.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Destination address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.
pub const destination_address = types.StringAttribute{
    .name = "destination.address",
    .brief = "Destination address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.",
    .note = "When observed from the source side, and when communicating through an intermediary, `destination.address` SHOULD represent the destination address behind any intermediaries, for example proxies, if it's available.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Destination port number
pub const destination_port = types.IntAttribute{
    .name = "destination.port",
    .brief = "Destination port number",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A unique identifier representing the device
pub const device_id = types.StringAttribute{
    .name = "device.id",
    .brief = "A unique identifier representing the device",
    .note = "Its value SHOULD be identical for all apps on a device and it SHOULD NOT change if an app is uninstalled and re-installed. However, it might be resettable by the user for all apps on a device. Hardware IDs (e.g. vendor-specific serial number, IMEI or MAC address) MAY be used as values.  More information about Android identifier best practices can be found [here](https://developer.android.com/training/articles/user-data-ids).  ] [!WARNING] ] ] This attribute may contain sensitive (PII) information. Caution should be taken when storing personal data or anything which can identify a user. GDPR and data protection laws may apply, ] ensure you do your own due diligence. ] ] Due to these reasons, this identifier is not recommended for consumer applications and will likely result in rejection from both Google Play and App Store. ] However, it may be appropriate for specific enterprise scenarios, such as kiosk devices or enterprise-managed devices, with appropriate compliance clearance. ] Any instrumentation providing this identifier MUST implement it as an opt-in feature. ] ] See [`app.installation.id`](/docs/registry/attributes/app.md#app-installation-id) for a more privacy-preserving alternative.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the device manufacturer
pub const device_manufacturer = types.StringAttribute{
    .name = "device.manufacturer",
    .brief = "The name of the device manufacturer",
    .note = "The Android OS provides this field via [Build](https://developer.android.com/reference/android/os/Build#MANUFACTURER). iOS apps SHOULD hardcode the value `Apple`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The model identifier for the device
pub const device_model_identifier = types.StringAttribute{
    .name = "device.model.identifier",
    .brief = "The model identifier for the device",
    .note = "It's recommended this value represents a machine-readable version of the model identifier rather than the market or consumer-friendly name of the device.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The marketing name for the device model
pub const device_model_name = types.StringAttribute{
    .name = "device.model.name",
    .brief = "The marketing name for the device model",
    .note = "It's recommended this value represents a human-readable version of the device model rather than a machine-readable alternative.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const disk_io_directionValue = enum {
    read,
    write,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .read => "read",
            .write => "write",
        };
    }
};

/// The disk IO operation direction.
pub const disk_io_direction = types.EnumAttribute(disk_io_directionValue){
    .name = "disk.io.direction",
    .brief = "The disk IO operation direction.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The list of IPv4 or IPv6 addresses resolved during DNS lookup.
pub const dns_answers = types.StringArrayAttribute{
    .name = "dns.answers",
    .brief = "The list of IPv4 or IPv6 addresses resolved during DNS lookup.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name being queried.
pub const dns_question_name = types.StringAttribute{
    .name = "dns.question.name",
    .brief = "The name being queried.",
    .note = "If the name field contains non-printable characters (below 32 or above 126), those characters should be represented as escaped base 10 integers (\\DDD). Back slashes and quotes should be escaped. Tabs, carriage returns, and line feeds should be converted to \\t, \\r, and \\n respectively.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const dotnet_gc_heap_generationValue = enum {
    gen0,
    gen1,
    gen2,
    loh,
    poh,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .gen0 => "gen0",
            .gen1 => "gen1",
            .gen2 => "gen2",
            .loh => "loh",
            .poh => "poh",
        };
    }
};

/// Name of the garbage collector managed heap generation.
pub const dotnet_gc_heap_generation = types.EnumAttribute(dotnet_gc_heap_generationValue){
    .name = "dotnet.gc.heap.generation",
    .brief = "Name of the garbage collector managed heap generation.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Represents the human-readable identifier of the node/instance to which a request was routed.
pub const elasticsearch_node_name = types.StringAttribute{
    .name = "elasticsearch.node.name",
    .brief = "Represents the human-readable identifier of the node/instance to which a request was routed.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Unique identifier of an end user in the system. It maybe a username, email address, or other identifier.
pub const enduser_id = types.StringAttribute{
    .name = "enduser.id",
    .brief = "Unique identifier of an end user in the system. It maybe a username, email address, or other identifier.",
    .note = "Unique identifier of an end user in the system.  ] [!Warning] ] This field contains sensitive (PII) information.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Pseudonymous identifier of an end user. This identifier should be a random value that is not directly linked or associated with the end user's actual identity.
pub const enduser_pseudo_id = types.StringAttribute{
    .name = "enduser.pseudo.id",
    .brief = "Pseudonymous identifier of an end user. This identifier should be a random value that is not directly linked or associated with the end user's actual identity.",
    .note = "Pseudonymous identifier of an end user.  ] [!Warning] ] This field contains sensitive (linkable PII) information.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `user.roles` instead.
pub const enduser_role = types.StringAttribute{
    .name = "enduser.role",
    .brief = "Deprecated, use `user.roles` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, no replacement at this time.
pub const enduser_scope = types.StringAttribute{
    .name = "enduser.scope",
    .brief = "Deprecated, no replacement at this time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A message providing more detail about an error in human-readable form.
pub const error_message = types.StringAttribute{
    .name = "error.message",
    .brief = "A message providing more detail about an error in human-readable form.",
    .note = "`error.message` should provide additional context and detail about an error. It is NOT RECOMMENDED to duplicate the value of `error.type` in `error.message`. It is also NOT RECOMMENDED to duplicate the value of `exception.message` in `error.message`.  `error.message` is NOT RECOMMENDED for metrics or spans due to its unbounded cardinality and overlap with span status.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const error_typeValue = enum {
    other,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .other => "_OTHER",
        };
    }
};

/// Describes a class of error the operation ended with.
pub const error_type = types.EnumAttribute(error_typeValue){
    .name = "error.type",
    .brief = "Describes a class of error the operation ended with.",
    .note = "The `error.type` SHOULD be predictable, and SHOULD have low cardinality.  When `error.type` is set to a type (e.g., an exception type), its canonical class name identifying the type within the artifact SHOULD be used.  Instrumentations SHOULD document the list of errors they report.  The cardinality of `error.type` within one instrumentation library SHOULD be low. Telemetry consumers that aggregate data from multiple instrumentation libraries and applications should be prepared for `error.type` to have high cardinality at query time when no additional filters are applied.  If the operation has completed successfully, instrumentations SHOULD NOT set `error.type`.  If a specific domain defines its own set of error identifiers (such as HTTP or gRPC status codes), it's RECOMMENDED to:  - Use a domain-specific attribute - Set `error.type` to capture all errors, regardless of whether they are defined within the domain-specific set or not.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Identifies the class / type of event.
pub const event_name = types.StringAttribute{
    .name = "event.name",
    .brief = "Identifies the class / type of event.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Indicates that the exception is escaping the scope of the span.
pub const exception_escaped = types.BooleanAttribute{
    .name = "exception.escaped",
    .brief = "Indicates that the exception is escaping the scope of the span.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The exception message.
pub const exception_message = types.StringAttribute{
    .name = "exception.message",
    .brief = "The exception message.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// A stacktrace as a string in the natural representation for the language runtime. The representation is to be determined and documented by each language SIG.
pub const exception_stacktrace = types.StringAttribute{
    .name = "exception.stacktrace",
    .brief = "A stacktrace as a string in the natural representation for the language runtime. The representation is to be determined and documented by each language SIG.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The type of the exception (its fully-qualified class name, if applicable). The dynamic type of the exception should be preferred over the static type in languages that support it.
pub const exception_type = types.StringAttribute{
    .name = "exception.type",
    .brief = "The type of the exception (its fully-qualified class name, if applicable). The dynamic type of the exception should be preferred over the static type in languages that support it.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// A boolean that is true if the serverless function is executed for the first time (aka cold-start).
pub const faas_coldstart = types.BooleanAttribute{
    .name = "faas.coldstart",
    .brief = "A boolean that is true if the serverless function is executed for the first time (aka cold-start).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A string containing the schedule period as [Cron Expression](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm).
pub const faas_cron = types.StringAttribute{
    .name = "faas.cron",
    .brief = "A string containing the schedule period as [Cron Expression](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the source on which the triggering operation was performed. For example, in Cloud Storage or S3 corresponds to the bucket name, and in Cosmos DB to the database name.
pub const faas_document_collection = types.StringAttribute{
    .name = "faas.document.collection",
    .brief = "The name of the source on which the triggering operation was performed. For example, in Cloud Storage or S3 corresponds to the bucket name, and in Cosmos DB to the database name.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The document name/table subjected to the operation. For example, in Cloud Storage or S3 is the name of the file, and in Cosmos DB the table name.
pub const faas_document_name = types.StringAttribute{
    .name = "faas.document.name",
    .brief = "The document name/table subjected to the operation. For example, in Cloud Storage or S3 is the name of the file, and in Cosmos DB the table name.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const faas_document_operationValue = enum {
    insert,
    edit,
    delete,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .insert => "insert",
            .edit => "edit",
            .delete => "delete",
        };
    }
};

/// Describes the type of the operation that was performed on the data.
pub const faas_document_operation = types.EnumAttribute(faas_document_operationValue){
    .name = "faas.document.operation",
    .brief = "Describes the type of the operation that was performed on the data.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A string containing the time when the data was accessed in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).
pub const faas_document_time = types.StringAttribute{
    .name = "faas.document.time",
    .brief = "A string containing the time when the data was accessed in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The execution environment ID as a string, that will be potentially reused for other invocations to the same function/function version.
pub const faas_instance = types.StringAttribute{
    .name = "faas.instance",
    .brief = "The execution environment ID as a string, that will be potentially reused for other invocations to the same function/function version.",
    .note = "- **AWS Lambda:** Use the (full) log stream name.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The invocation ID of the current function invocation.
pub const faas_invocation_id = types.StringAttribute{
    .name = "faas.invocation_id",
    .brief = "The invocation ID of the current function invocation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the invoked function.
pub const faas_invoked_name = types.StringAttribute{
    .name = "faas.invoked_name",
    .brief = "The name of the invoked function.",
    .note = "SHOULD be equal to the `faas.name` resource attribute of the invoked function.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const faas_invoked_providerValue = enum {
    alibaba_cloud,
    aws,
    azure,
    gcp,
    tencent_cloud,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .alibaba_cloud => "alibaba_cloud",
            .aws => "aws",
            .azure => "azure",
            .gcp => "gcp",
            .tencent_cloud => "tencent_cloud",
        };
    }
};

/// The cloud provider of the invoked function.
pub const faas_invoked_provider = types.EnumAttribute(faas_invoked_providerValue){
    .name = "faas.invoked_provider",
    .brief = "The cloud provider of the invoked function.",
    .note = "SHOULD be equal to the `cloud.provider` resource attribute of the invoked function.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The cloud region of the invoked function.
pub const faas_invoked_region = types.StringAttribute{
    .name = "faas.invoked_region",
    .brief = "The cloud region of the invoked function.",
    .note = "SHOULD be equal to the `cloud.region` resource attribute of the invoked function.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The amount of memory available to the serverless function converted to Bytes.
pub const faas_max_memory = types.IntAttribute{
    .name = "faas.max_memory",
    .brief = "The amount of memory available to the serverless function converted to Bytes.",
    .note = "It's recommended to set this attribute since e.g. too little memory can easily stop a Java AWS Lambda function from working correctly. On AWS Lambda, the environment variable `AWS_LAMBDA_FUNCTION_MEMORY_SIZE` provides this information (which must be multiplied by 1,048,576).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the single function that this runtime instance executes.
pub const faas_name = types.StringAttribute{
    .name = "faas.name",
    .brief = "The name of the single function that this runtime instance executes.",
    .note = "This is the name of the function as configured/deployed on the FaaS platform and is usually different from the name of the callback function (which may be stored in the [`code.namespace`/`code.function.name`](/docs/general/attributes.md#source-code-attributes) span attributes).  For some cloud providers, the above definition is ambiguous. The following definition of function name MUST be used for this attribute (and consequently the span name) for the listed cloud providers/products:  - **Azure:**  The full name `[FUNCAPP]/[FUNC]`, i.e., function app name   followed by a forward slash followed by the function name (this form   can also be seen in the resource JSON for the function).   This means that a span attribute MUST be used, as an Azure function   app can host multiple functions that would usually share   a TracerProvider (see also the `cloud.resource_id` attribute).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A string containing the function invocation time in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).
pub const faas_time = types.StringAttribute{
    .name = "faas.time",
    .brief = "A string containing the function invocation time in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const faas_triggerValue = enum {
    datasource,
    http,
    pubsub,
    timer,
    other,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .datasource => "datasource",
            .http => "http",
            .pubsub => "pubsub",
            .timer => "timer",
            .other => "other",
        };
    }
};

/// Type of the trigger which caused this function invocation.
pub const faas_trigger = types.EnumAttribute(faas_triggerValue){
    .name = "faas.trigger",
    .brief = "Type of the trigger which caused this function invocation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The immutable version of the function being executed.
pub const faas_version = types.StringAttribute{
    .name = "faas.version",
    .brief = "The immutable version of the function being executed.",
    .note = "Depending on the cloud provider and platform, use:  - **AWS Lambda:** The [function version](https://docs.aws.amazon.com/lambda/latest/dg/configuration-versions.html)   (an integer represented as a decimal string). - **Google Cloud Run (Services):** The [revision](https://cloud.google.com/run/docs/managing/revisions)   (i.e., the function name plus the revision suffix). - **Google Cloud Functions:** The value of the   [`K_REVISION` environment variable](https://cloud.google.com/functions/docs/env-var#runtime_environment_variables_set_automatically). - **Azure Functions:** Not applicable. Do not set this attribute.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier for the flag evaluation context. For example, the targeting key.
pub const feature_flag_context_id = types.StringAttribute{
    .name = "feature_flag.context.id",
    .brief = "The unique identifier for the flag evaluation context. For example, the targeting key.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `error.message` instead.
pub const feature_flag_evaluation_error_message = types.StringAttribute{
    .name = "feature_flag.evaluation.error.message",
    .brief = "Deprecated, use `error.message` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const feature_flag_evaluation_reasonValue = enum {
    static,
    default,
    targeting_match,
    split,
    cached,
    disabled,
    unknown,
    stale,
    @"error",
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .static => "static",
            .default => "default",
            .targeting_match => "targeting_match",
            .split => "split",
            .cached => "cached",
            .disabled => "disabled",
            .unknown => "unknown",
            .stale => "stale",
            .@"error" => "error",
        };
    }
};

/// Deprecated, use `feature_flag.result.reason` instead.
pub const feature_flag_evaluation_reason = types.EnumAttribute(feature_flag_evaluation_reasonValue){
    .name = "feature_flag.evaluation.reason",
    .brief = "Deprecated, use `feature_flag.result.reason` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The lookup key of the feature flag.
pub const feature_flag_key = types.StringAttribute{
    .name = "feature_flag.key",
    .brief = "The lookup key of the feature flag.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Identifies the feature flag provider.
pub const feature_flag_provider_name = types.StringAttribute{
    .name = "feature_flag.provider.name",
    .brief = "Identifies the feature flag provider.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const feature_flag_result_reasonValue = enum {
    static,
    default,
    targeting_match,
    split,
    cached,
    disabled,
    unknown,
    stale,
    @"error",
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .static => "static",
            .default => "default",
            .targeting_match => "targeting_match",
            .split => "split",
            .cached => "cached",
            .disabled => "disabled",
            .unknown => "unknown",
            .stale => "stale",
            .@"error" => "error",
        };
    }
};

/// The reason code which shows how a feature flag value was determined.
pub const feature_flag_result_reason = types.EnumAttribute(feature_flag_result_reasonValue){
    .name = "feature_flag.result.reason",
    .brief = "The reason code which shows how a feature flag value was determined.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The evaluated value of the feature flag.
pub const feature_flag_result_value = types.StringAttribute{
    .name = "feature_flag.result.value",
    .brief = "The evaluated value of the feature flag.",
    .note = "With some feature flag providers, feature flag results can be quite large or contain private or sensitive details. Because of this, `feature_flag.result.variant` is often the preferred attribute if it is available.  It may be desirable to redact or otherwise limit the size and scope of `feature_flag.result.value` if possible. Because the evaluated flag value is unstructured and may be any type, it is left to the instrumentation author to determine how best to achieve this.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A semantic identifier for an evaluated flag value.
pub const feature_flag_result_variant = types.StringAttribute{
    .name = "feature_flag.result.variant",
    .brief = "A semantic identifier for an evaluated flag value.",
    .note = "A semantic identifier, commonly referred to as a variant, provides a means for referring to a value without including the value itself. This can provide additional context for understanding the meaning behind a value. For example, the variant `red` maybe be used for the value `#c05543`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The identifier of the [flag set](https://openfeature.dev/specification/glossary/#flag-set) to which the feature flag belongs.
pub const feature_flag_set_id = types.StringAttribute{
    .name = "feature_flag.set.id",
    .brief = "The identifier of the [flag set](https://openfeature.dev/specification/glossary/#flag-set) to which the feature flag belongs.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `feature_flag.result.variant` instead.
pub const feature_flag_variant = types.StringAttribute{
    .name = "feature_flag.variant",
    .brief = "Deprecated, use `feature_flag.result.variant` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version of the ruleset used during the evaluation. This may be any stable value which uniquely identifies the ruleset.
pub const feature_flag_version = types.StringAttribute{
    .name = "feature_flag.version",
    .brief = "The version of the ruleset used during the evaluation. This may be any stable value which uniquely identifies the ruleset.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Time when the file was last accessed, in ISO 8601 format.
pub const file_accessed = types.StringAttribute{
    .name = "file.accessed",
    .brief = "Time when the file was last accessed, in ISO 8601 format.",
    .note = "This attribute might not be supported by some file systems — NFS, FAT32, in embedded OS, etc.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Array of file attributes.
pub const file_attributes = types.StringArrayAttribute{
    .name = "file.attributes",
    .brief = "Array of file attributes.",
    .note = "Attributes names depend on the OS or file system. Here’s a non-exhaustive list of values expected for this attribute: `archive`, `compressed`, `directory`, `encrypted`, `execute`, `hidden`, `immutable`, `journaled`, `read`, `readonly`, `symbolic link`, `system`, `temporary`, `write`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Time when the file attributes or metadata was last changed, in ISO 8601 format.
pub const file_changed = types.StringAttribute{
    .name = "file.changed",
    .brief = "Time when the file attributes or metadata was last changed, in ISO 8601 format.",
    .note = "`file.changed` captures the time when any of the file's properties or attributes (including the content) are changed, while `file.modified` captures the timestamp when the file content is modified.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Time when the file was created, in ISO 8601 format.
pub const file_created = types.StringAttribute{
    .name = "file.created",
    .brief = "Time when the file was created, in ISO 8601 format.",
    .note = "This attribute might not be supported by some file systems — NFS, FAT32, in embedded OS, etc.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Directory where the file is located. It should include the drive letter, when appropriate.
pub const file_directory = types.StringAttribute{
    .name = "file.directory",
    .brief = "Directory where the file is located. It should include the drive letter, when appropriate.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// File extension, excluding the leading dot.
pub const file_extension = types.StringAttribute{
    .name = "file.extension",
    .brief = "File extension, excluding the leading dot.",
    .note = "When the file name has multiple extensions (example.tar.gz), only the last one should be captured (\"gz\", not \"tar.gz\").",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the fork. A fork is additional data associated with a filesystem object.
pub const file_fork_name = types.StringAttribute{
    .name = "file.fork_name",
    .brief = "Name of the fork. A fork is additional data associated with a filesystem object.",
    .note = "On Linux, a resource fork is used to store additional data with a filesystem object. A file always has at least one fork for the data portion, and additional forks may exist. On NTFS, this is analogous to an Alternate Data Stream (ADS), and the default data stream for a file is just called $DATA. Zone.Identifier is commonly used by Windows to track contents downloaded from the Internet. An ADS is typically of the form: C:\\path\\to\\filename.extension:some_fork_name, and some_fork_name is the value that should populate `fork_name`. `filename.extension` should populate `file.name`, and `extension` should populate `file.extension`. The full path, `file.path`, will include the fork name.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Primary Group ID (GID) of the file.
pub const file_group_id = types.StringAttribute{
    .name = "file.group.id",
    .brief = "Primary Group ID (GID) of the file.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Primary group name of the file.
pub const file_group_name = types.StringAttribute{
    .name = "file.group.name",
    .brief = "Primary group name of the file.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Inode representing the file in the filesystem.
pub const file_inode = types.StringAttribute{
    .name = "file.inode",
    .brief = "Inode representing the file in the filesystem.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Mode of the file in octal representation.
pub const file_mode = types.StringAttribute{
    .name = "file.mode",
    .brief = "Mode of the file in octal representation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Time when the file content was last modified, in ISO 8601 format.
pub const file_modified = types.StringAttribute{
    .name = "file.modified",
    .brief = "Time when the file content was last modified, in ISO 8601 format.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the file including the extension, without the directory.
pub const file_name = types.StringAttribute{
    .name = "file.name",
    .brief = "Name of the file including the extension, without the directory.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The user ID (UID) or security identifier (SID) of the file owner.
pub const file_owner_id = types.StringAttribute{
    .name = "file.owner.id",
    .brief = "The user ID (UID) or security identifier (SID) of the file owner.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Username of the file owner.
pub const file_owner_name = types.StringAttribute{
    .name = "file.owner.name",
    .brief = "Username of the file owner.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Full path to the file, including the file name. It should include the drive letter, when appropriate.
pub const file_path = types.StringAttribute{
    .name = "file.path",
    .brief = "Full path to the file, including the file name. It should include the drive letter, when appropriate.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// File size in bytes.
pub const file_size = types.IntAttribute{
    .name = "file.size",
    .brief = "File size in bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Path to the target of a symbolic link.
pub const file_symbolic_link_target_path = types.StringAttribute{
    .name = "file.symbolic_link.target_path",
    .brief = "Path to the target of a symbolic link.",
    .note = "This attribute is only applicable to symbolic links.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The container within GCP where the AppHub application is defined.
pub const gcp_apphub_application_container = types.StringAttribute{
    .name = "gcp.apphub.application.container",
    .brief = "The container within GCP where the AppHub application is defined.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the application as configured in AppHub.
pub const gcp_apphub_application_id = types.StringAttribute{
    .name = "gcp.apphub.application.id",
    .brief = "The name of the application as configured in AppHub.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The GCP zone or region where the application is defined.
pub const gcp_apphub_application_location = types.StringAttribute{
    .name = "gcp.apphub.application.location",
    .brief = "The GCP zone or region where the application is defined.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gcp_apphub_service_criticality_typeValue = enum {
    mission_critical,
    high,
    medium,
    low,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .mission_critical => "MISSION_CRITICAL",
            .high => "HIGH",
            .medium => "MEDIUM",
            .low => "LOW",
        };
    }
};

/// Criticality of a service indicates its importance to the business.
pub const gcp_apphub_service_criticality_type = types.EnumAttribute(gcp_apphub_service_criticality_typeValue){
    .name = "gcp.apphub.service.criticality_type",
    .brief = "Criticality of a service indicates its importance to the business.",
    .note = "[See AppHub type enum](https://cloud.google.com/app-hub/docs/reference/rest/v1/Attributes#type)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gcp_apphub_service_environment_typeValue = enum {
    production,
    staging,
    @"test",
    development,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .production => "PRODUCTION",
            .staging => "STAGING",
            .@"test" => "TEST",
            .development => "DEVELOPMENT",
        };
    }
};

/// Environment of a service is the stage of a software lifecycle.
pub const gcp_apphub_service_environment_type = types.EnumAttribute(gcp_apphub_service_environment_typeValue){
    .name = "gcp.apphub.service.environment_type",
    .brief = "Environment of a service is the stage of a software lifecycle.",
    .note = "[See AppHub environment type](https://cloud.google.com/app-hub/docs/reference/rest/v1/Attributes#type_1)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the service as configured in AppHub.
pub const gcp_apphub_service_id = types.StringAttribute{
    .name = "gcp.apphub.service.id",
    .brief = "The name of the service as configured in AppHub.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gcp_apphub_workload_criticality_typeValue = enum {
    mission_critical,
    high,
    medium,
    low,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .mission_critical => "MISSION_CRITICAL",
            .high => "HIGH",
            .medium => "MEDIUM",
            .low => "LOW",
        };
    }
};

/// Criticality of a workload indicates its importance to the business.
pub const gcp_apphub_workload_criticality_type = types.EnumAttribute(gcp_apphub_workload_criticality_typeValue){
    .name = "gcp.apphub.workload.criticality_type",
    .brief = "Criticality of a workload indicates its importance to the business.",
    .note = "[See AppHub type enum](https://cloud.google.com/app-hub/docs/reference/rest/v1/Attributes#type)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gcp_apphub_workload_environment_typeValue = enum {
    production,
    staging,
    @"test",
    development,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .production => "PRODUCTION",
            .staging => "STAGING",
            .@"test" => "TEST",
            .development => "DEVELOPMENT",
        };
    }
};

/// Environment of a workload is the stage of a software lifecycle.
pub const gcp_apphub_workload_environment_type = types.EnumAttribute(gcp_apphub_workload_environment_typeValue){
    .name = "gcp.apphub.workload.environment_type",
    .brief = "Environment of a workload is the stage of a software lifecycle.",
    .note = "[See AppHub environment type](https://cloud.google.com/app-hub/docs/reference/rest/v1/Attributes#type_1)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the workload as configured in AppHub.
pub const gcp_apphub_workload_id = types.StringAttribute{
    .name = "gcp.apphub.workload.id",
    .brief = "The name of the workload as configured in AppHub.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Identifies the Google Cloud service for which the official client library is intended.
pub const gcp_client_service = types.StringAttribute{
    .name = "gcp.client.service",
    .brief = "Identifies the Google Cloud service for which the official client library is intended.",
    .note = "Intended to be a stable identifier for Google Cloud client libraries that is uniform across implementation languages. The value should be derived from the canonical service domain for the service; for example, 'foo.googleapis.com' should result in a value of 'foo'.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the Cloud Run [execution](https://cloud.google.com/run/docs/managing/job-executions) being run for the Job, as set by the [`CLOUD_RUN_EXECUTION`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.
pub const gcp_cloud_run_job_execution = types.StringAttribute{
    .name = "gcp.cloud_run.job.execution",
    .brief = "The name of the Cloud Run [execution](https://cloud.google.com/run/docs/managing/job-executions) being run for the Job, as set by the [`CLOUD_RUN_EXECUTION`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The index for a task within an execution as provided by the [`CLOUD_RUN_TASK_INDEX`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.
pub const gcp_cloud_run_job_task_index = types.IntAttribute{
    .name = "gcp.cloud_run.job.task_index",
    .brief = "The index for a task within an execution as provided by the [`CLOUD_RUN_TASK_INDEX`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The hostname of a GCE instance. This is the full value of the default or [custom hostname](https://cloud.google.com/compute/docs/instances/custom-hostname-vm).
pub const gcp_gce_instance_hostname = types.StringAttribute{
    .name = "gcp.gce.instance.hostname",
    .brief = "The hostname of a GCE instance. This is the full value of the default or [custom hostname](https://cloud.google.com/compute/docs/instances/custom-hostname-vm).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The instance name of a GCE instance. This is the value provided by `host.name`, the visible name of the instance in the Cloud Console UI, and the prefix for the default hostname of the instance as defined by the [default internal DNS name](https://cloud.google.com/compute/docs/internal-dns#instance-fully-qualified-domain-names).
pub const gcp_gce_instance_name = types.StringAttribute{
    .name = "gcp.gce.instance.name",
    .brief = "The instance name of a GCE instance. This is the value provided by `host.name`, the visible name of the instance in the Cloud Console UI, and the prefix for the default hostname of the instance as defined by the [default internal DNS name](https://cloud.google.com/compute/docs/internal-dns#instance-fully-qualified-domain-names).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Free-form description of the GenAI agent provided by the application.
pub const gen_ai_agent_description = types.StringAttribute{
    .name = "gen_ai.agent.description",
    .brief = "Free-form description of the GenAI agent provided by the application.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier of the GenAI agent.
pub const gen_ai_agent_id = types.StringAttribute{
    .name = "gen_ai.agent.id",
    .brief = "The unique identifier of the GenAI agent.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Human-readable name of the GenAI agent provided by the application.
pub const gen_ai_agent_name = types.StringAttribute{
    .name = "gen_ai.agent.name",
    .brief = "Human-readable name of the GenAI agent provided by the application.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use Event API to report completions contents.
pub const gen_ai_completion = types.StringAttribute{
    .name = "gen_ai.completion",
    .brief = "Deprecated, use Event API to report completions contents.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier for a conversation (session, thread), used to store and correlate messages within this conversation.
pub const gen_ai_conversation_id = types.StringAttribute{
    .name = "gen_ai.conversation.id",
    .brief = "The unique identifier for a conversation (session, thread), used to store and correlate messages within this conversation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The data source identifier.
pub const gen_ai_data_source_id = types.StringAttribute{
    .name = "gen_ai.data_source.id",
    .brief = "The data source identifier.",
    .note = "Data sources are used by AI agents and RAG applications to store grounding data. A data source may be an external database, object store, document collection, website, or any other storage system used by the GenAI agent or application. The `gen_ai.data_source.id` SHOULD match the identifier used by the GenAI system rather than a name specific to the external storage, such as a database or object store. Semantic conventions referencing `gen_ai.data_source.id` MAY also leverage additional attributes, such as `db.*`, to further identify and describe the data source.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gen_ai_openai_request_response_formatValue = enum {
    text,
    json_object,
    json_schema,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .text => "text",
            .json_object => "json_object",
            .json_schema => "json_schema",
        };
    }
};

/// Deprecated, use `gen_ai.output.type`.
pub const gen_ai_openai_request_response_format = types.EnumAttribute(gen_ai_openai_request_response_formatValue){
    .name = "gen_ai.openai.request.response_format",
    .brief = "Deprecated, use `gen_ai.output.type`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `gen_ai.request.seed`.
pub const gen_ai_openai_request_seed = types.IntAttribute{
    .name = "gen_ai.openai.request.seed",
    .brief = "Deprecated, use `gen_ai.request.seed`.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gen_ai_openai_request_service_tierValue = enum {
    auto,
    default,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .auto => "auto",
            .default => "default",
        };
    }
};

/// The service tier requested. May be a specific tier, default, or auto.
pub const gen_ai_openai_request_service_tier = types.EnumAttribute(gen_ai_openai_request_service_tierValue){
    .name = "gen_ai.openai.request.service_tier",
    .brief = "The service tier requested. May be a specific tier, default, or auto.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The service tier used for the response.
pub const gen_ai_openai_response_service_tier = types.StringAttribute{
    .name = "gen_ai.openai.response.service_tier",
    .brief = "The service tier used for the response.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A fingerprint to track any eventual change in the Generative AI environment.
pub const gen_ai_openai_response_system_fingerprint = types.StringAttribute{
    .name = "gen_ai.openai.response.system_fingerprint",
    .brief = "A fingerprint to track any eventual change in the Generative AI environment.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gen_ai_operation_nameValue = enum {
    chat,
    generate_content,
    text_completion,
    embeddings,
    create_agent,
    invoke_agent,
    execute_tool,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .chat => "chat",
            .generate_content => "generate_content",
            .text_completion => "text_completion",
            .embeddings => "embeddings",
            .create_agent => "create_agent",
            .invoke_agent => "invoke_agent",
            .execute_tool => "execute_tool",
        };
    }
};

/// The name of the operation being performed.
pub const gen_ai_operation_name = types.EnumAttribute(gen_ai_operation_nameValue){
    .name = "gen_ai.operation.name",
    .brief = "The name of the operation being performed.",
    .note = "If one of the predefined values applies, but specific system uses a different name it's RECOMMENDED to document it in the semantic conventions for specific GenAI system and use system-specific name in the instrumentation. If a different name is not documented, instrumentation libraries SHOULD use applicable predefined value.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gen_ai_output_typeValue = enum {
    text,
    json,
    image,
    speech,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .text => "text",
            .json => "json",
            .image => "image",
            .speech => "speech",
        };
    }
};

/// Represents the content type requested by the client.
pub const gen_ai_output_type = types.EnumAttribute(gen_ai_output_typeValue){
    .name = "gen_ai.output.type",
    .brief = "Represents the content type requested by the client.",
    .note = "This attribute SHOULD be used when the client requests output of a specific type. The model may return zero or more outputs of this type. This attribute specifies the output modality and not the actual output format. For example, if an image is requested, the actual output could be a URL pointing to an image file. Additional output format details may be recorded in the future in the `gen_ai.output.{type}.*` attributes.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use Event API to report prompt contents.
pub const gen_ai_prompt = types.StringAttribute{
    .name = "gen_ai.prompt",
    .brief = "Deprecated, use Event API to report prompt contents.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The target number of candidate completions to return.
pub const gen_ai_request_choice_count = types.IntAttribute{
    .name = "gen_ai.request.choice.count",
    .brief = "The target number of candidate completions to return.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The encoding formats requested in an embeddings operation, if specified.
pub const gen_ai_request_encoding_formats = types.StringArrayAttribute{
    .name = "gen_ai.request.encoding_formats",
    .brief = "The encoding formats requested in an embeddings operation, if specified.",
    .note = "In some GenAI systems the encoding formats are called embedding types. Also, some GenAI systems only accept a single format per request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The frequency penalty setting for the GenAI request.
pub const gen_ai_request_frequency_penalty = types.DoubleAttribute{
    .name = "gen_ai.request.frequency_penalty",
    .brief = "The frequency penalty setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The maximum number of tokens the model generates for a request.
pub const gen_ai_request_max_tokens = types.IntAttribute{
    .name = "gen_ai.request.max_tokens",
    .brief = "The maximum number of tokens the model generates for a request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the GenAI model a request is being made to.
pub const gen_ai_request_model = types.StringAttribute{
    .name = "gen_ai.request.model",
    .brief = "The name of the GenAI model a request is being made to.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The presence penalty setting for the GenAI request.
pub const gen_ai_request_presence_penalty = types.DoubleAttribute{
    .name = "gen_ai.request.presence_penalty",
    .brief = "The presence penalty setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Requests with same seed value more likely to return same result.
pub const gen_ai_request_seed = types.IntAttribute{
    .name = "gen_ai.request.seed",
    .brief = "Requests with same seed value more likely to return same result.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// List of sequences that the model will use to stop generating further tokens.
pub const gen_ai_request_stop_sequences = types.StringArrayAttribute{
    .name = "gen_ai.request.stop_sequences",
    .brief = "List of sequences that the model will use to stop generating further tokens.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The temperature setting for the GenAI request.
pub const gen_ai_request_temperature = types.DoubleAttribute{
    .name = "gen_ai.request.temperature",
    .brief = "The temperature setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The top_k sampling setting for the GenAI request.
pub const gen_ai_request_top_k = types.DoubleAttribute{
    .name = "gen_ai.request.top_k",
    .brief = "The top_k sampling setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The top_p sampling setting for the GenAI request.
pub const gen_ai_request_top_p = types.DoubleAttribute{
    .name = "gen_ai.request.top_p",
    .brief = "The top_p sampling setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Array of reasons the model stopped generating tokens, corresponding to each generation received.
pub const gen_ai_response_finish_reasons = types.StringArrayAttribute{
    .name = "gen_ai.response.finish_reasons",
    .brief = "Array of reasons the model stopped generating tokens, corresponding to each generation received.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The unique identifier for the completion.
pub const gen_ai_response_id = types.StringAttribute{
    .name = "gen_ai.response.id",
    .brief = "The unique identifier for the completion.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the model that generated the response.
pub const gen_ai_response_model = types.StringAttribute{
    .name = "gen_ai.response.model",
    .brief = "The name of the model that generated the response.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gen_ai_systemValue = enum {
    openai,
    gcp_gen_ai,
    gcp_vertex_ai,
    gcp_gemini,
    vertex_ai,
    gemini,
    anthropic,
    cohere,
    azure_ai_inference,
    azure_ai_openai,
    az_ai_inference,
    az_ai_openai,
    ibm_watsonx_ai,
    aws_bedrock,
    perplexity,
    xai,
    deepseek,
    groq,
    mistral_ai,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .openai => "openai",
            .gcp_gen_ai => "gcp.gen_ai",
            .gcp_vertex_ai => "gcp.vertex_ai",
            .gcp_gemini => "gcp.gemini",
            .vertex_ai => "vertex_ai",
            .gemini => "gemini",
            .anthropic => "anthropic",
            .cohere => "cohere",
            .azure_ai_inference => "azure.ai.inference",
            .azure_ai_openai => "azure.ai.openai",
            .az_ai_inference => "az.ai.inference",
            .az_ai_openai => "azure.ai.openai",
            .ibm_watsonx_ai => "ibm.watsonx.ai",
            .aws_bedrock => "aws.bedrock",
            .perplexity => "perplexity",
            .xai => "xai",
            .deepseek => "deepseek",
            .groq => "groq",
            .mistral_ai => "mistral_ai",
        };
    }
};

/// The Generative AI product as identified by the client or server instrumentation.
pub const gen_ai_system = types.EnumAttribute(gen_ai_systemValue){
    .name = "gen_ai.system",
    .brief = "The Generative AI product as identified by the client or server instrumentation.",
    .note = "The `gen_ai.system` describes a family of GenAI models with specific model identified by `gen_ai.request.model` and `gen_ai.response.model` attributes.  The actual GenAI product may differ from the one identified by the client. Multiple systems, including Azure OpenAI and Gemini, are accessible by OpenAI client libraries. In such cases, the `gen_ai.system` is set to `openai` based on the instrumentation's best knowledge, instead of the actual system. The `server.address` attribute may help identify the actual system in use for `openai`.  For custom model, a custom friendly name SHOULD be used. If none of these options apply, the `gen_ai.system` SHOULD be set to `_OTHER`.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const gen_ai_token_typeValue = enum {
    input,
    completion,
    output,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .input => "input",
            .completion => "output",
            .output => "output",
        };
    }
};

/// The type of token being counted.
pub const gen_ai_token_type = types.EnumAttribute(gen_ai_token_typeValue){
    .name = "gen_ai.token.type",
    .brief = "The type of token being counted.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The tool call identifier.
pub const gen_ai_tool_call_id = types.StringAttribute{
    .name = "gen_ai.tool.call.id",
    .brief = "The tool call identifier.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The tool description.
pub const gen_ai_tool_description = types.StringAttribute{
    .name = "gen_ai.tool.description",
    .brief = "The tool description.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the tool utilized by the agent.
pub const gen_ai_tool_name = types.StringAttribute{
    .name = "gen_ai.tool.name",
    .brief = "Name of the tool utilized by the agent.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Type of the tool utilized by the agent
pub const gen_ai_tool_type = types.StringAttribute{
    .name = "gen_ai.tool.type",
    .brief = "Type of the tool utilized by the agent",
    .note = "Extension: A tool executed on the agent-side to directly call external APIs, bridging the gap between the agent and real-world systems.   Agent-side operations involve actions that are performed by the agent on the server or within the agent's controlled environment. Function: A tool executed on the client-side, where the agent generates parameters for a predefined function, and the client executes the logic.   Client-side operations are actions taken on the user's end or within the client application. Datastore: A tool used by the agent to access and query structured or unstructured external data for retrieval-augmented tasks or knowledge updates.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `gen_ai.usage.output_tokens` instead.
pub const gen_ai_usage_completion_tokens = types.IntAttribute{
    .name = "gen_ai.usage.completion_tokens",
    .brief = "Deprecated, use `gen_ai.usage.output_tokens` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The number of tokens used in the GenAI input (prompt).
pub const gen_ai_usage_input_tokens = types.IntAttribute{
    .name = "gen_ai.usage.input_tokens",
    .brief = "The number of tokens used in the GenAI input (prompt).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The number of tokens used in the GenAI response (completion).
pub const gen_ai_usage_output_tokens = types.IntAttribute{
    .name = "gen_ai.usage.output_tokens",
    .brief = "The number of tokens used in the GenAI response (completion).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `gen_ai.usage.input_tokens` instead.
pub const gen_ai_usage_prompt_tokens = types.IntAttribute{
    .name = "gen_ai.usage.prompt_tokens",
    .brief = "Deprecated, use `gen_ai.usage.input_tokens` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const geo_continent_codeValue = enum {
    af,
    an,
    as,
    eu,
    na,
    oc,
    sa,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .af => "AF",
            .an => "AN",
            .as => "AS",
            .eu => "EU",
            .na => "NA",
            .oc => "OC",
            .sa => "SA",
        };
    }
};

/// Two-letter code representing continent’s name.
pub const geo_continent_code = types.EnumAttribute(geo_continent_codeValue){
    .name = "geo.continent.code",
    .brief = "Two-letter code representing continent’s name.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Two-letter ISO Country Code ([ISO 3166-1 alpha2](https://wikipedia.org/wiki/ISO_3166-1#Codes)).
pub const geo_country_iso_code = types.StringAttribute{
    .name = "geo.country.iso_code",
    .brief = "Two-letter ISO Country Code ([ISO 3166-1 alpha2](https://wikipedia.org/wiki/ISO_3166-1#Codes)).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Locality name. Represents the name of a city, town, village, or similar populated place.
pub const geo_locality_name = types.StringAttribute{
    .name = "geo.locality.name",
    .brief = "Locality name. Represents the name of a city, town, village, or similar populated place.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Latitude of the geo location in [WGS84](https://wikipedia.org/wiki/World_Geodetic_System#WGS84).
pub const geo_location_lat = types.DoubleAttribute{
    .name = "geo.location.lat",
    .brief = "Latitude of the geo location in [WGS84](https://wikipedia.org/wiki/World_Geodetic_System#WGS84).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Longitude of the geo location in [WGS84](https://wikipedia.org/wiki/World_Geodetic_System#WGS84).
pub const geo_location_lon = types.DoubleAttribute{
    .name = "geo.location.lon",
    .brief = "Longitude of the geo location in [WGS84](https://wikipedia.org/wiki/World_Geodetic_System#WGS84).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Postal code associated with the location. Values appropriate for this field may also be known as a postcode or ZIP code and will vary widely from country to country.
pub const geo_postal_code = types.StringAttribute{
    .name = "geo.postal_code",
    .brief = "Postal code associated with the location. Values appropriate for this field may also be known as a postcode or ZIP code and will vary widely from country to country.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Region ISO code ([ISO 3166-2](https://wikipedia.org/wiki/ISO_3166-2)).
pub const geo_region_iso_code = types.StringAttribute{
    .name = "geo.region.iso_code",
    .brief = "Region ISO code ([ISO 3166-2](https://wikipedia.org/wiki/ISO_3166-2)).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const go_memory_typeValue = enum {
    stack,
    other,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .stack => "stack",
            .other => "other",
        };
    }
};

/// The type of memory.
pub const go_memory_type = types.EnumAttribute(go_memory_typeValue){
    .name = "go.memory.type",
    .brief = "The type of memory.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The GraphQL document being executed.
pub const graphql_document = types.StringAttribute{
    .name = "graphql.document",
    .brief = "The GraphQL document being executed.",
    .note = "The value may be sanitized to exclude sensitive information.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the operation being executed.
pub const graphql_operation_name = types.StringAttribute{
    .name = "graphql.operation.name",
    .brief = "The name of the operation being executed.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const graphql_operation_typeValue = enum {
    query,
    mutation,
    subscription,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .query => "query",
            .mutation => "mutation",
            .subscription => "subscription",
        };
    }
};

/// The type of the operation being executed.
pub const graphql_operation_type = types.EnumAttribute(graphql_operation_typeValue){
    .name = "graphql.operation.type",
    .brief = "The type of the operation being executed.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Unique identifier for the application
pub const heroku_app_id = types.StringAttribute{
    .name = "heroku.app.id",
    .brief = "Unique identifier for the application",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Commit hash for the current release
pub const heroku_release_commit = types.StringAttribute{
    .name = "heroku.release.commit",
    .brief = "Commit hash for the current release",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Time and date the release was created
pub const heroku_release_creation_timestamp = types.StringAttribute{
    .name = "heroku.release.creation_timestamp",
    .brief = "Time and date the release was created",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const host_archValue = enum {
    amd64,
    arm32,
    arm64,
    ia64,
    ppc32,
    ppc64,
    s390x,
    x86,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .amd64 => "amd64",
            .arm32 => "arm32",
            .arm64 => "arm64",
            .ia64 => "ia64",
            .ppc32 => "ppc32",
            .ppc64 => "ppc64",
            .s390x => "s390x",
            .x86 => "x86",
        };
    }
};

/// The CPU architecture the host system is running on.
pub const host_arch = types.EnumAttribute(host_archValue){
    .name = "host.arch",
    .brief = "The CPU architecture the host system is running on.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The amount of level 2 memory cache available to the processor (in Bytes).
pub const host_cpu_cache_l2_size = types.IntAttribute{
    .name = "host.cpu.cache.l2.size",
    .brief = "The amount of level 2 memory cache available to the processor (in Bytes).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Family or generation of the CPU.
pub const host_cpu_family = types.StringAttribute{
    .name = "host.cpu.family",
    .brief = "Family or generation of the CPU.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Model identifier. It provides more granular information about the CPU, distinguishing it from other CPUs within the same family.
pub const host_cpu_model_id = types.StringAttribute{
    .name = "host.cpu.model.id",
    .brief = "Model identifier. It provides more granular information about the CPU, distinguishing it from other CPUs within the same family.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Model designation of the processor.
pub const host_cpu_model_name = types.StringAttribute{
    .name = "host.cpu.model.name",
    .brief = "Model designation of the processor.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Stepping or core revisions.
pub const host_cpu_stepping = types.StringAttribute{
    .name = "host.cpu.stepping",
    .brief = "Stepping or core revisions.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Processor manufacturer identifier. A maximum 12-character string.
pub const host_cpu_vendor_id = types.StringAttribute{
    .name = "host.cpu.vendor.id",
    .brief = "Processor manufacturer identifier. A maximum 12-character string.",
    .note = "[CPUID](https://wiki.osdev.org/CPUID) command returns the vendor ID string in EBX, EDX and ECX registers. Writing these to memory in this order results in a 12-character string.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Unique host ID. For Cloud, this must be the instance_id assigned by the cloud provider. For non-containerized systems, this should be the `machine-id`. See the table below for the sources to use to determine the `machine-id` based on operating system.
pub const host_id = types.StringAttribute{
    .name = "host.id",
    .brief = "Unique host ID. For Cloud, this must be the instance_id assigned by the cloud provider. For non-containerized systems, this should be the `machine-id`. See the table below for the sources to use to determine the `machine-id` based on operating system.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// VM image ID or host OS image ID. For Cloud, this value is from the provider.
pub const host_image_id = types.StringAttribute{
    .name = "host.image.id",
    .brief = "VM image ID or host OS image ID. For Cloud, this value is from the provider.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the VM image or OS install the host was instantiated from.
pub const host_image_name = types.StringAttribute{
    .name = "host.image.name",
    .brief = "Name of the VM image or OS install the host was instantiated from.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version string of the VM image or host OS as defined in [Version Attributes](/docs/resource/README.md#version-attributes).
pub const host_image_version = types.StringAttribute{
    .name = "host.image.version",
    .brief = "The version string of the VM image or host OS as defined in [Version Attributes](/docs/resource/README.md#version-attributes).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Available IP addresses of the host, excluding loopback interfaces.
pub const host_ip = types.StringArrayAttribute{
    .name = "host.ip",
    .brief = "Available IP addresses of the host, excluding loopback interfaces.",
    .note = "IPv4 Addresses MUST be specified in dotted-quad notation. IPv6 addresses MUST be specified in the [RFC 5952](https://www.rfc-editor.org/rfc/rfc5952.html) format.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Available MAC addresses of the host, excluding loopback interfaces.
pub const host_mac = types.StringArrayAttribute{
    .name = "host.mac",
    .brief = "Available MAC addresses of the host, excluding loopback interfaces.",
    .note = "MAC Addresses MUST be represented in [IEEE RA hexadecimal form](https://standards.ieee.org/wp-content/uploads/import/documents/tutorials/eui.pdf): as hyphen-separated octets in uppercase hexadecimal form from most to least significant.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the host. On Unix systems, it may contain what the hostname command returns, or the fully qualified hostname, or another name specified by the user.
pub const host_name = types.StringAttribute{
    .name = "host.name",
    .brief = "Name of the host. On Unix systems, it may contain what the hostname command returns, or the fully qualified hostname, or another name specified by the user.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Type of host. For Cloud, this must be the machine type.
pub const host_type = types.StringAttribute{
    .name = "host.type",
    .brief = "Type of host. For Cloud, this must be the machine type.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `client.address` instead.
pub const http_client_ip = types.StringAttribute{
    .name = "http.client_ip",
    .brief = "Deprecated, use `client.address` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const http_connection_stateValue = enum {
    active,
    idle,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .active => "active",
            .idle => "idle",
        };
    }
};

/// State of the HTTP connection in the HTTP connection pool.
pub const http_connection_state = types.EnumAttribute(http_connection_stateValue){
    .name = "http.connection.state",
    .brief = "State of the HTTP connection in the HTTP connection pool.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const http_flavorValue = enum {
    http_1_0,
    http_1_1,
    http_2_0,
    http_3_0,
    spdy,
    quic,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .http_1_0 => "1.0",
            .http_1_1 => "1.1",
            .http_2_0 => "2.0",
            .http_3_0 => "3.0",
            .spdy => "SPDY",
            .quic => "QUIC",
        };
    }
};

/// Deprecated, use `network.protocol.name` instead.
pub const http_flavor = types.EnumAttribute(http_flavorValue){
    .name = "http.flavor",
    .brief = "Deprecated, use `network.protocol.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use one of `server.address`, `client.address` or `http.request.header.host` instead, depending on the usage.
pub const http_host = types.StringAttribute{
    .name = "http.host",
    .brief = "Deprecated, use one of `server.address`, `client.address` or `http.request.header.host` instead, depending on the usage.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `http.request.method` instead.
pub const http_method = types.StringAttribute{
    .name = "http.method",
    .brief = "Deprecated, use `http.request.method` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
pub const http_request_body_size = types.IntAttribute{
    .name = "http.request.body.size",
    .brief = "The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// HTTP request headers, ``key`` being the normalized HTTP Header name (lowercase), the value being the header values.
pub const http_request_header = types.StringArrayAttribute{
    .name = "http.request.header",
    .brief = "HTTP request headers, ``key`` being the normalized HTTP Header name (lowercase), the value being the header values.",
    .note = "Instrumentations SHOULD require an explicit configuration of which headers are to be captured. Including all request headers can be a security risk - explicit configuration helps avoid leaking sensitive information.  The `User-Agent` header is already captured in the `user_agent.original` attribute. Users MAY explicitly configure instrumentations to capture them even though it is not recommended.  The attribute value MUST consist of either multiple header values as an array of strings or a single-item array containing a possibly comma-concatenated string, depending on the way the HTTP library provides access to headers.  Examples:  - A header `Content-Type: application/json` SHOULD be recorded as the `http.request.header.content-type`   attribute with value `[\"application/json\"]`. - A header `X-Forwarded-For: 1.2.3.4, 1.2.3.5` SHOULD be recorded as the `http.request.header.x-forwarded-for`   attribute with value `[\"1.2.3.4\", \"1.2.3.5\"]` or `[\"1.2.3.4, 1.2.3.5\"]` depending on the HTTP library.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const http_request_methodValue = enum {
    connect,
    delete,
    get,
    head,
    options,
    patch,
    post,
    put,
    trace,
    other,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .connect => "CONNECT",
            .delete => "DELETE",
            .get => "GET",
            .head => "HEAD",
            .options => "OPTIONS",
            .patch => "PATCH",
            .post => "POST",
            .put => "PUT",
            .trace => "TRACE",
            .other => "_OTHER",
        };
    }
};

/// HTTP request method.
pub const http_request_method = types.EnumAttribute(http_request_methodValue){
    .name = "http.request.method",
    .brief = "HTTP request method.",
    .note = "HTTP request method value SHOULD be \"known\" to the instrumentation. By default, this convention defines \"known\" methods as the ones listed in [RFC9110](https://www.rfc-editor.org/rfc/rfc9110.html#name-methods) and the PATCH method defined in [RFC5789](https://www.rfc-editor.org/rfc/rfc5789.html).  If the HTTP request method is not known to instrumentation, it MUST set the `http.request.method` attribute to `_OTHER`.  If the HTTP instrumentation could end up converting valid HTTP request methods to `_OTHER`, then it MUST provide a way to override the list of known HTTP methods. If this override is done via environment variable, then the environment variable MUST be named OTEL_INSTRUMENTATION_HTTP_KNOWN_METHODS and support a comma-separated list of case-sensitive known HTTP methods (this list MUST be a full override of the default known method, it is not a list of known methods in addition to the defaults).  HTTP method names are case-sensitive and `http.request.method` attribute value MUST match a known HTTP method name exactly. Instrumentations for specific web frameworks that consider HTTP methods to be case insensitive, SHOULD populate a canonical equivalent. Tracing instrumentations that do so, MUST also set `http.request.method_original` to the original value.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Original HTTP method sent by the client in the request line.
pub const http_request_method_original = types.StringAttribute{
    .name = "http.request.method_original",
    .brief = "Original HTTP method sent by the client in the request line.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The ordinal number of request resending attempt (for any reason, including redirects).
pub const http_request_resend_count = types.IntAttribute{
    .name = "http.request.resend_count",
    .brief = "The ordinal number of request resending attempt (for any reason, including redirects).",
    .note = "The resend count SHOULD be updated each time an HTTP request gets resent by the client, regardless of what was the cause of the resending (e.g. redirection, authorization failure, 503 Server Unavailable, network issues, or any other).",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The total size of the request in bytes. This should be the total number of bytes sent over the wire, including the request line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and request body if any.
pub const http_request_size = types.IntAttribute{
    .name = "http.request.size",
    .brief = "The total size of the request in bytes. This should be the total number of bytes sent over the wire, including the request line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and request body if any.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `http.request.header.content-length` instead.
pub const http_request_content_length = types.IntAttribute{
    .name = "http.request_content_length",
    .brief = "Deprecated, use `http.request.header.content-length` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `http.request.body.size` instead.
pub const http_request_content_length_uncompressed = types.IntAttribute{
    .name = "http.request_content_length_uncompressed",
    .brief = "Deprecated, use `http.request.body.size` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
pub const http_response_body_size = types.IntAttribute{
    .name = "http.response.body.size",
    .brief = "The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// HTTP response headers, ``key`` being the normalized HTTP Header name (lowercase), the value being the header values.
pub const http_response_header = types.StringArrayAttribute{
    .name = "http.response.header",
    .brief = "HTTP response headers, ``key`` being the normalized HTTP Header name (lowercase), the value being the header values.",
    .note = "Instrumentations SHOULD require an explicit configuration of which headers are to be captured. Including all response headers can be a security risk - explicit configuration helps avoid leaking sensitive information.  Users MAY explicitly configure instrumentations to capture them even though it is not recommended.  The attribute value MUST consist of either multiple header values as an array of strings or a single-item array containing a possibly comma-concatenated string, depending on the way the HTTP library provides access to headers.  Examples:  - A header `Content-Type: application/json` header SHOULD be recorded as the `http.request.response.content-type`   attribute with value `[\"application/json\"]`. - A header `My-custom-header: abc, def` header SHOULD be recorded as the `http.response.header.my-custom-header`   attribute with value `[\"abc\", \"def\"]` or `[\"abc, def\"]` depending on the HTTP library.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The total size of the response in bytes. This should be the total number of bytes sent over the wire, including the status line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and response body and trailers if any.
pub const http_response_size = types.IntAttribute{
    .name = "http.response.size",
    .brief = "The total size of the response in bytes. This should be the total number of bytes sent over the wire, including the status line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and response body and trailers if any.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// [HTTP response status code](https://tools.ietf.org/html/rfc7231#section-6).
pub const http_response_status_code = types.IntAttribute{
    .name = "http.response.status_code",
    .brief = "[HTTP response status code](https://tools.ietf.org/html/rfc7231#section-6).",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `http.response.header.content-length` instead.
pub const http_response_content_length = types.IntAttribute{
    .name = "http.response_content_length",
    .brief = "Deprecated, use `http.response.header.content-length` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `http.response.body.size` instead.
pub const http_response_content_length_uncompressed = types.IntAttribute{
    .name = "http.response_content_length_uncompressed",
    .brief = "Deprecated, use `http.response.body.size` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The matched route, that is, the path template in the format used by the respective server framework.
pub const http_route = types.StringAttribute{
    .name = "http.route",
    .brief = "The matched route, that is, the path template in the format used by the respective server framework.",
    .note = "MUST NOT be populated when this is not supported by the HTTP server framework as the route attribute should have low-cardinality and the URI path can NOT substitute it. SHOULD include the [application root](/docs/http/http-spans.md#http-server-definitions) if there is one.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Deprecated, use `url.scheme` instead.
pub const http_scheme = types.StringAttribute{
    .name = "http.scheme",
    .brief = "Deprecated, use `url.scheme` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `server.address` instead.
pub const http_server_name = types.StringAttribute{
    .name = "http.server_name",
    .brief = "Deprecated, use `server.address` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `http.response.status_code` instead.
pub const http_status_code = types.IntAttribute{
    .name = "http.status_code",
    .brief = "Deprecated, use `http.response.status_code` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `url.path` and `url.query` instead.
pub const http_target = types.StringAttribute{
    .name = "http.target",
    .brief = "Deprecated, use `url.path` and `url.query` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `url.full` instead.
pub const http_url = types.StringAttribute{
    .name = "http.url",
    .brief = "Deprecated, use `url.full` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `user_agent.original` instead.
pub const http_user_agent = types.StringAttribute{
    .name = "http.user_agent",
    .brief = "Deprecated, use `user_agent.original` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// An identifier for the hardware component, unique within the monitored host
pub const hw_id = types.StringAttribute{
    .name = "hw.id",
    .brief = "An identifier for the hardware component, unique within the monitored host",
    .stability = .development,
    .requirement_level = .recommended,
};
/// An easily-recognizable name for the hardware component
pub const hw_name = types.StringAttribute{
    .name = "hw.name",
    .brief = "An easily-recognizable name for the hardware component",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Unique identifier of the parent component (typically the `hw.id` attribute of the enclosure, or disk controller)
pub const hw_parent = types.StringAttribute{
    .name = "hw.parent",
    .brief = "Unique identifier of the parent component (typically the `hw.id` attribute of the enclosure, or disk controller)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const hw_stateValue = enum {
    ok,
    degraded,
    failed,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .ok => "ok",
            .degraded => "degraded",
            .failed => "failed",
        };
    }
};

/// The current state of the component
pub const hw_state = types.EnumAttribute(hw_stateValue){
    .name = "hw.state",
    .brief = "The current state of the component",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const hw_typeValue = enum {
    battery,
    cpu,
    disk_controller,
    enclosure,
    fan,
    gpu,
    logical_disk,
    memory,
    network,
    physical_disk,
    power_supply,
    tape_drive,
    temperature,
    voltage,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .battery => "battery",
            .cpu => "cpu",
            .disk_controller => "disk_controller",
            .enclosure => "enclosure",
            .fan => "fan",
            .gpu => "gpu",
            .logical_disk => "logical_disk",
            .memory => "memory",
            .network => "network",
            .physical_disk => "physical_disk",
            .power_supply => "power_supply",
            .tape_drive => "tape_drive",
            .temperature => "temperature",
            .voltage => "voltage",
        };
    }
};

/// Type of the component
pub const hw_type = types.EnumAttribute(hw_typeValue){
    .name = "hw.type",
    .brief = "Type of the component",
    .note = "Describes the category of the hardware component for which `hw.state` is being reported. For example, `hw.type=temperature` along with `hw.state=degraded` would indicate that the temperature of the hardware component has been reported as `degraded`.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const ios_app_stateValue = enum {
    active,
    inactive,
    background,
    foreground,
    terminate,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .active => "active",
            .inactive => "inactive",
            .background => "background",
            .foreground => "foreground",
            .terminate => "terminate",
        };
    }
};

/// This attribute represents the state of the application.
pub const ios_app_state = types.EnumAttribute(ios_app_stateValue){
    .name = "ios.app.state",
    .brief = "This attribute represents the state of the application.",
    .note = "The iOS lifecycle states are defined in the [UIApplicationDelegate documentation](https://developer.apple.com/documentation/uikit/uiapplicationdelegate), and from which the `OS terminology` column values are derived.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const ios_stateValue = enum {
    active,
    inactive,
    background,
    foreground,
    terminate,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .active => "active",
            .inactive => "inactive",
            .background => "background",
            .foreground => "foreground",
            .terminate => "terminate",
        };
    }
};

///
pub const ios_state = types.EnumAttribute(ios_stateValue){
    .name = "ios.state",
    .brief = "",
    .note = "The iOS lifecycle states are defined in the [UIApplicationDelegate documentation](https://developer.apple.com/documentation/uikit/uiapplicationdelegate), and from which the `OS terminology` column values are derived.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the buffer pool.
pub const jvm_buffer_pool_name = types.StringAttribute{
    .name = "jvm.buffer.pool.name",
    .brief = "Name of the buffer pool.",
    .note = "Pool names are generally obtained via [BufferPoolMXBean#getName()](https://docs.oracle.com/en/java/javase/11/docs/api/java.management/java/lang/management/BufferPoolMXBean.html#getName()).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the garbage collector action.
pub const jvm_gc_action = types.StringAttribute{
    .name = "jvm.gc.action",
    .brief = "Name of the garbage collector action.",
    .note = "Garbage collector action is generally obtained via [GarbageCollectionNotificationInfo#getGcAction()](https://docs.oracle.com/en/java/javase/11/docs/api/jdk.management/com/sun/management/GarbageCollectionNotificationInfo.html#getGcAction()).",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Name of the garbage collector cause.
pub const jvm_gc_cause = types.StringAttribute{
    .name = "jvm.gc.cause",
    .brief = "Name of the garbage collector cause.",
    .note = "Garbage collector cause is generally obtained via [GarbageCollectionNotificationInfo#getGcCause()](https://docs.oracle.com/en/java/javase/11/docs/api/jdk.management/com/sun/management/GarbageCollectionNotificationInfo.html#getGcCause()).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the garbage collector.
pub const jvm_gc_name = types.StringAttribute{
    .name = "jvm.gc.name",
    .brief = "Name of the garbage collector.",
    .note = "Garbage collector name is generally obtained via [GarbageCollectionNotificationInfo#getGcName()](https://docs.oracle.com/en/java/javase/11/docs/api/jdk.management/com/sun/management/GarbageCollectionNotificationInfo.html#getGcName()).",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Name of the memory pool.
pub const jvm_memory_pool_name = types.StringAttribute{
    .name = "jvm.memory.pool.name",
    .brief = "Name of the memory pool.",
    .note = "Pool names are generally obtained via [MemoryPoolMXBean#getName()](https://docs.oracle.com/en/java/javase/11/docs/api/java.management/java/lang/management/MemoryPoolMXBean.html#getName()).",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const jvm_memory_typeValue = enum {
    heap,
    non_heap,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .heap => "heap",
            .non_heap => "non_heap",
        };
    }
};

/// The type of memory.
pub const jvm_memory_type = types.EnumAttribute(jvm_memory_typeValue){
    .name = "jvm.memory.type",
    .brief = "The type of memory.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Whether the thread is daemon or not.
pub const jvm_thread_daemon = types.BooleanAttribute{
    .name = "jvm.thread.daemon",
    .brief = "Whether the thread is daemon or not.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const jvm_thread_stateValue = enum {
    new,
    runnable,
    blocked,
    waiting,
    timed_waiting,
    terminated,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .new => "new",
            .runnable => "runnable",
            .blocked => "blocked",
            .waiting => "waiting",
            .timed_waiting => "timed_waiting",
            .terminated => "terminated",
        };
    }
};

/// State of the thread.
pub const jvm_thread_state = types.EnumAttribute(jvm_thread_stateValue){
    .name = "jvm.thread.state",
    .brief = "State of the thread.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The name of the cluster.
pub const k8s_cluster_name = types.StringAttribute{
    .name = "k8s.cluster.name",
    .brief = "The name of the cluster.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A pseudo-ID for the cluster, set to the UID of the `kube-system` namespace.
pub const k8s_cluster_uid = types.StringAttribute{
    .name = "k8s.cluster.uid",
    .brief = "A pseudo-ID for the cluster, set to the UID of the `kube-system` namespace.",
    .note = "K8s doesn't have support for obtaining a cluster ID. If this is ever added, we will recommend collecting the `k8s.cluster.uid` through the official APIs. In the meantime, we are able to use the `uid` of the `kube-system` namespace as a proxy for cluster ID. Read on for the rationale.  Every object created in a K8s cluster is assigned a distinct UID. The `kube-system` namespace is used by Kubernetes itself and will exist for the lifetime of the cluster. Using the `uid` of the `kube-system` namespace is a reasonable proxy for the K8s ClusterID as it will only change if the cluster is rebuilt. Furthermore, Kubernetes UIDs are UUIDs as standardized by [ISO/IEC 9834-8 and ITU-T X.667](https://www.itu.int/ITU-T/studygroups/com17/oid.html). Which states:  ] If generated according to one of the mechanisms defined in Rec. ] ITU-T X.667 | ISO/IEC 9834-8, a UUID is either guaranteed to be ] different from all other UUIDs generated before 3603 A.D., or is ] extremely likely to be different (depending on the mechanism chosen).  Therefore, UIDs between clusters should be extremely unlikely to conflict.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the Container from Pod specification, must be unique within a Pod. Container runtime usually uses different globally unique name (`container.name`).
pub const k8s_container_name = types.StringAttribute{
    .name = "k8s.container.name",
    .brief = "The name of the Container from Pod specification, must be unique within a Pod. Container runtime usually uses different globally unique name (`container.name`).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Number of times the container was restarted. This attribute can be used to identify a particular container (running or stopped) within a container spec.
pub const k8s_container_restart_count = types.IntAttribute{
    .name = "k8s.container.restart_count",
    .brief = "Number of times the container was restarted. This attribute can be used to identify a particular container (running or stopped) within a container spec.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Last terminated reason of the Container.
pub const k8s_container_status_last_terminated_reason = types.StringAttribute{
    .name = "k8s.container.status.last_terminated_reason",
    .brief = "Last terminated reason of the Container.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const k8s_container_status_reasonValue = enum {
    container_creating,
    crash_loop_back_off,
    create_container_config_error,
    err_image_pull,
    image_pull_back_off,
    oom_killed,
    completed,
    @"error",
    container_cannot_run,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .container_creating => "ContainerCreating",
            .crash_loop_back_off => "CrashLoopBackOff",
            .create_container_config_error => "CreateContainerConfigError",
            .err_image_pull => "ErrImagePull",
            .image_pull_back_off => "ImagePullBackOff",
            .oom_killed => "OOMKilled",
            .completed => "Completed",
            .@"error" => "Error",
            .container_cannot_run => "ContainerCannotRun",
        };
    }
};

/// The reason for the container state. Corresponds to the `reason` field of the: [K8s ContainerStateWaiting](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#containerstatewaiting-v1-core) or [K8s ContainerStateTerminated](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#containerstateterminated-v1-core)
pub const k8s_container_status_reason = types.EnumAttribute(k8s_container_status_reasonValue){
    .name = "k8s.container.status.reason",
    .brief = "The reason for the container state. Corresponds to the `reason` field of the: [K8s ContainerStateWaiting](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#containerstatewaiting-v1-core) or [K8s ContainerStateTerminated](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#containerstateterminated-v1-core)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const k8s_container_status_stateValue = enum {
    terminated,
    running,
    waiting,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .terminated => "terminated",
            .running => "running",
            .waiting => "waiting",
        };
    }
};

/// The state of the container. [K8s ContainerState](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#containerstate-v1-core)
pub const k8s_container_status_state = types.EnumAttribute(k8s_container_status_stateValue){
    .name = "k8s.container.status.state",
    .brief = "The state of the container. [K8s ContainerState](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#containerstate-v1-core)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The cronjob annotation placed on the CronJob, the ``key`` being the annotation name, the value being the annotation value.
pub const k8s_cronjob_annotation = types.StringAttribute{
    .name = "k8s.cronjob.annotation",
    .brief = "The cronjob annotation placed on the CronJob, the ``key`` being the annotation name, the value being the annotation value.",
    .note = "Examples:  - An annotation `retries` with value `4` SHOULD be recorded as the   `k8s.cronjob.annotation.retries` attribute with value `\"4\"`. - An annotation `data` with empty string value SHOULD be recorded as   the `k8s.cronjob.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the CronJob, the ``key`` being the label name, the value being the label value.
pub const k8s_cronjob_label = types.StringAttribute{
    .name = "k8s.cronjob.label",
    .brief = "The label placed on the CronJob, the ``key`` being the label name, the value being the label value.",
    .note = "Examples:  - A label `type` with value `weekly` SHOULD be recorded as the   `k8s.cronjob.label.type` attribute with value `\"weekly\"`. - A label `automated` with empty string value SHOULD be recorded as   the `k8s.cronjob.label.automated` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the CronJob.
pub const k8s_cronjob_name = types.StringAttribute{
    .name = "k8s.cronjob.name",
    .brief = "The name of the CronJob.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the CronJob.
pub const k8s_cronjob_uid = types.StringAttribute{
    .name = "k8s.cronjob.uid",
    .brief = "The UID of the CronJob.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the DaemonSet, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.
pub const k8s_daemonset_annotation = types.StringAttribute{
    .name = "k8s.daemonset.annotation",
    .brief = "The annotation placed on the DaemonSet, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.",
    .note = "Examples:  - A label `replicas` with value `1` SHOULD be recorded   as the `k8s.daemonset.annotation.replicas` attribute with value `\"1\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.daemonset.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the DaemonSet, the ``key`` being the label name, the value being the label value, even if the value is empty.
pub const k8s_daemonset_label = types.StringAttribute{
    .name = "k8s.daemonset.label",
    .brief = "The label placed on the DaemonSet, the ``key`` being the label name, the value being the label value, even if the value is empty.",
    .note = "Examples:  - A label `app` with value `guestbook` SHOULD be recorded   as the `k8s.daemonset.label.app` attribute with value `\"guestbook\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.daemonset.label.injected` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the DaemonSet.
pub const k8s_daemonset_name = types.StringAttribute{
    .name = "k8s.daemonset.name",
    .brief = "The name of the DaemonSet.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the DaemonSet.
pub const k8s_daemonset_uid = types.StringAttribute{
    .name = "k8s.daemonset.uid",
    .brief = "The UID of the DaemonSet.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the Deployment, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.
pub const k8s_deployment_annotation = types.StringAttribute{
    .name = "k8s.deployment.annotation",
    .brief = "The annotation placed on the Deployment, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.",
    .note = "Examples:  - A label `replicas` with value `1` SHOULD be recorded   as the `k8s.deployment.annotation.replicas` attribute with value `\"1\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.deployment.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the Deployment, the ``key`` being the label name, the value being the label value, even if the value is empty.
pub const k8s_deployment_label = types.StringAttribute{
    .name = "k8s.deployment.label",
    .brief = "The label placed on the Deployment, the ``key`` being the label name, the value being the label value, even if the value is empty.",
    .note = "Examples:  - A label `replicas` with value `0` SHOULD be recorded   as the `k8s.deployment.label.app` attribute with value `\"guestbook\"`. - A label `injected` with empty string value SHOULD be recorded as   the `k8s.deployment.label.injected` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the Deployment.
pub const k8s_deployment_name = types.StringAttribute{
    .name = "k8s.deployment.name",
    .brief = "The name of the Deployment.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the Deployment.
pub const k8s_deployment_uid = types.StringAttribute{
    .name = "k8s.deployment.uid",
    .brief = "The UID of the Deployment.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The type of metric source for the horizontal pod autoscaler.
pub const k8s_hpa_metric_type = types.StringAttribute{
    .name = "k8s.hpa.metric.type",
    .brief = "The type of metric source for the horizontal pod autoscaler.",
    .note = "This attribute reflects the `type` field of spec.metrics[] in the HPA.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the horizontal pod autoscaler.
pub const k8s_hpa_name = types.StringAttribute{
    .name = "k8s.hpa.name",
    .brief = "The name of the horizontal pod autoscaler.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The API version of the target resource to scale for the HorizontalPodAutoscaler.
pub const k8s_hpa_scaletargetref_api_version = types.StringAttribute{
    .name = "k8s.hpa.scaletargetref.api_version",
    .brief = "The API version of the target resource to scale for the HorizontalPodAutoscaler.",
    .note = "This maps to the `apiVersion` field in the `scaleTargetRef` of the HPA spec.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The kind of the target resource to scale for the HorizontalPodAutoscaler.
pub const k8s_hpa_scaletargetref_kind = types.StringAttribute{
    .name = "k8s.hpa.scaletargetref.kind",
    .brief = "The kind of the target resource to scale for the HorizontalPodAutoscaler.",
    .note = "This maps to the `kind` field in the `scaleTargetRef` of the HPA spec.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the target resource to scale for the HorizontalPodAutoscaler.
pub const k8s_hpa_scaletargetref_name = types.StringAttribute{
    .name = "k8s.hpa.scaletargetref.name",
    .brief = "The name of the target resource to scale for the HorizontalPodAutoscaler.",
    .note = "This maps to the `name` field in the `scaleTargetRef` of the HPA spec.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the horizontal pod autoscaler.
pub const k8s_hpa_uid = types.StringAttribute{
    .name = "k8s.hpa.uid",
    .brief = "The UID of the horizontal pod autoscaler.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The size (identifier) of the K8s huge page.
pub const k8s_hugepage_size = types.StringAttribute{
    .name = "k8s.hugepage.size",
    .brief = "The size (identifier) of the K8s huge page.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the Job, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.
pub const k8s_job_annotation = types.StringAttribute{
    .name = "k8s.job.annotation",
    .brief = "The annotation placed on the Job, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.",
    .note = "Examples:  - A label `number` with value `1` SHOULD be recorded   as the `k8s.job.annotation.number` attribute with value `\"1\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.job.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the Job, the ``key`` being the label name, the value being the label value, even if the value is empty.
pub const k8s_job_label = types.StringAttribute{
    .name = "k8s.job.label",
    .brief = "The label placed on the Job, the ``key`` being the label name, the value being the label value, even if the value is empty.",
    .note = "Examples:  - A label `jobtype` with value `ci` SHOULD be recorded   as the `k8s.job.label.jobtype` attribute with value `\"ci\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.job.label.automated` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the Job.
pub const k8s_job_name = types.StringAttribute{
    .name = "k8s.job.name",
    .brief = "The name of the Job.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the Job.
pub const k8s_job_uid = types.StringAttribute{
    .name = "k8s.job.uid",
    .brief = "The UID of the Job.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the Namespace, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.
pub const k8s_namespace_annotation = types.StringAttribute{
    .name = "k8s.namespace.annotation",
    .brief = "The annotation placed on the Namespace, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.",
    .note = "Examples:  - A label `ttl` with value `0` SHOULD be recorded   as the `k8s.namespace.annotation.ttl` attribute with value `\"0\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.namespace.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the Namespace, the ``key`` being the label name, the value being the label value, even if the value is empty.
pub const k8s_namespace_label = types.StringAttribute{
    .name = "k8s.namespace.label",
    .brief = "The label placed on the Namespace, the ``key`` being the label name, the value being the label value, even if the value is empty.",
    .note = "Examples:  - A label `kubernetes.io/metadata.name` with value `default` SHOULD be recorded   as the `k8s.namespace.label.kubernetes.io/metadata.name` attribute with value `\"default\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.namespace.label.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the namespace that the pod is running in.
pub const k8s_namespace_name = types.StringAttribute{
    .name = "k8s.namespace.name",
    .brief = "The name of the namespace that the pod is running in.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const k8s_namespace_phaseValue = enum {
    active,
    terminating,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .active => "active",
            .terminating => "terminating",
        };
    }
};

/// The phase of the K8s namespace.
pub const k8s_namespace_phase = types.EnumAttribute(k8s_namespace_phaseValue){
    .name = "k8s.namespace.phase",
    .brief = "The phase of the K8s namespace.",
    .note = "This attribute aligns with the `phase` field of the [K8s NamespaceStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#namespacestatus-v1-core)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the Node, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.
pub const k8s_node_annotation = types.StringAttribute{
    .name = "k8s.node.annotation",
    .brief = "The annotation placed on the Node, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.",
    .note = "Examples:  - An annotation `node.alpha.kubernetes.io/ttl` with value `0` SHOULD be recorded as   the `k8s.node.annotation.node.alpha.kubernetes.io/ttl` attribute with value `\"0\"`. - An annotation `data` with empty string value SHOULD be recorded as   the `k8s.node.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const k8s_node_condition_statusValue = enum {
    condition_true,
    condition_false,
    condition_unknown,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .condition_true => "true",
            .condition_false => "false",
            .condition_unknown => "unknown",
        };
    }
};

/// The status of the condition, one of True, False, Unknown.
pub const k8s_node_condition_status = types.EnumAttribute(k8s_node_condition_statusValue){
    .name = "k8s.node.condition.status",
    .brief = "The status of the condition, one of True, False, Unknown.",
    .note = "This attribute aligns with the `status` field of the [NodeCondition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#nodecondition-v1-core)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const k8s_node_condition_typeValue = enum {
    ready,
    disk_pressure,
    memory_pressure,
    pid_pressure,
    network_unavailable,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .ready => "Ready",
            .disk_pressure => "DiskPressure",
            .memory_pressure => "MemoryPressure",
            .pid_pressure => "PIDPressure",
            .network_unavailable => "NetworkUnavailable",
        };
    }
};

/// The condition type of a K8s Node.
pub const k8s_node_condition_type = types.EnumAttribute(k8s_node_condition_typeValue){
    .name = "k8s.node.condition.type",
    .brief = "The condition type of a K8s Node.",
    .note = "K8s Node conditions as described by [K8s documentation](https://v1-32.docs.kubernetes.io/docs/reference/node/node-status/#condition).  This attribute aligns with the `type` field of the [NodeCondition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#nodecondition-v1-core)  The set of possible values is not limited to those listed here. Managed Kubernetes environments, or custom controllers MAY introduce additional node condition types. When this occurs, the exact value as reported by the Kubernetes API SHOULD be used.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the Node, the ``key`` being the label name, the value being the label value, even if the value is empty.
pub const k8s_node_label = types.StringAttribute{
    .name = "k8s.node.label",
    .brief = "The label placed on the Node, the ``key`` being the label name, the value being the label value, even if the value is empty.",
    .note = "Examples:  - A label `kubernetes.io/arch` with value `arm64` SHOULD be recorded   as the `k8s.node.label.kubernetes.io/arch` attribute with value `\"arm64\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.node.label.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the Node.
pub const k8s_node_name = types.StringAttribute{
    .name = "k8s.node.name",
    .brief = "The name of the Node.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the Node.
pub const k8s_node_uid = types.StringAttribute{
    .name = "k8s.node.uid",
    .brief = "The UID of the Node.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the Pod, the ``key`` being the annotation name, the value being the annotation value.
pub const k8s_pod_annotation = types.StringAttribute{
    .name = "k8s.pod.annotation",
    .brief = "The annotation placed on the Pod, the ``key`` being the annotation name, the value being the annotation value.",
    .note = "Examples:  - An annotation `kubernetes.io/enforce-mountable-secrets` with value `true` SHOULD be recorded as   the `k8s.pod.annotation.kubernetes.io/enforce-mountable-secrets` attribute with value `\"true\"`. - An annotation `mycompany.io/arch` with value `x64` SHOULD be recorded as   the `k8s.pod.annotation.mycompany.io/arch` attribute with value `\"x64\"`. - An annotation `data` with empty string value SHOULD be recorded as   the `k8s.pod.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the Pod, the ``key`` being the label name, the value being the label value.
pub const k8s_pod_label = types.StringAttribute{
    .name = "k8s.pod.label",
    .brief = "The label placed on the Pod, the ``key`` being the label name, the value being the label value.",
    .note = "Examples:  - A label `app` with value `my-app` SHOULD be recorded as   the `k8s.pod.label.app` attribute with value `\"my-app\"`. - A label `mycompany.io/arch` with value `x64` SHOULD be recorded as   the `k8s.pod.label.mycompany.io/arch` attribute with value `\"x64\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.pod.label.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `k8s.pod.label` instead.
pub const k8s_pod_labels = types.StringAttribute{
    .name = "k8s.pod.labels",
    .brief = "Deprecated, use `k8s.pod.label` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the Pod.
pub const k8s_pod_name = types.StringAttribute{
    .name = "k8s.pod.name",
    .brief = "The name of the Pod.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the Pod.
pub const k8s_pod_uid = types.StringAttribute{
    .name = "k8s.pod.uid",
    .brief = "The UID of the Pod.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the ReplicaSet, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.
pub const k8s_replicaset_annotation = types.StringAttribute{
    .name = "k8s.replicaset.annotation",
    .brief = "The annotation placed on the ReplicaSet, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.",
    .note = "Examples:  - A label `replicas` with value `0` SHOULD be recorded   as the `k8s.replicaset.annotation.replicas` attribute with value `\"0\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.replicaset.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the ReplicaSet, the ``key`` being the label name, the value being the label value, even if the value is empty.
pub const k8s_replicaset_label = types.StringAttribute{
    .name = "k8s.replicaset.label",
    .brief = "The label placed on the ReplicaSet, the ``key`` being the label name, the value being the label value, even if the value is empty.",
    .note = "Examples:  - A label `app` with value `guestbook` SHOULD be recorded   as the `k8s.replicaset.label.app` attribute with value `\"guestbook\"`. - A label `injected` with empty string value SHOULD be recorded as   the `k8s.replicaset.label.injected` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the ReplicaSet.
pub const k8s_replicaset_name = types.StringAttribute{
    .name = "k8s.replicaset.name",
    .brief = "The name of the ReplicaSet.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the ReplicaSet.
pub const k8s_replicaset_uid = types.StringAttribute{
    .name = "k8s.replicaset.uid",
    .brief = "The UID of the ReplicaSet.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the replication controller.
pub const k8s_replicationcontroller_name = types.StringAttribute{
    .name = "k8s.replicationcontroller.name",
    .brief = "The name of the replication controller.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the replication controller.
pub const k8s_replicationcontroller_uid = types.StringAttribute{
    .name = "k8s.replicationcontroller.uid",
    .brief = "The UID of the replication controller.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the resource quota.
pub const k8s_resourcequota_name = types.StringAttribute{
    .name = "k8s.resourcequota.name",
    .brief = "The name of the resource quota.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the K8s resource a resource quota defines.
pub const k8s_resourcequota_resource_name = types.StringAttribute{
    .name = "k8s.resourcequota.resource_name",
    .brief = "The name of the K8s resource a resource quota defines.",
    .note = "The value for this attribute can be either the full `count/[resource][.[group]]` string (e.g., count/deployments.apps, count/pods), or, for certain core Kubernetes resources, just the resource name (e.g., pods, services, configmaps). Both forms are supported by Kubernetes for object count quotas. See [Kubernetes Resource Quotas documentation](https://kubernetes.io/docs/concepts/policy/resource-quotas/#object-count-quota) for more details.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the resource quota.
pub const k8s_resourcequota_uid = types.StringAttribute{
    .name = "k8s.resourcequota.uid",
    .brief = "The UID of the resource quota.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The annotation placed on the StatefulSet, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.
pub const k8s_statefulset_annotation = types.StringAttribute{
    .name = "k8s.statefulset.annotation",
    .brief = "The annotation placed on the StatefulSet, the ``key`` being the annotation name, the value being the annotation value, even if the value is empty.",
    .note = "Examples:  - A label `replicas` with value `1` SHOULD be recorded   as the `k8s.statefulset.annotation.replicas` attribute with value `\"1\"`. - A label `data` with empty string value SHOULD be recorded as   the `k8s.statefulset.annotation.data` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The label placed on the StatefulSet, the ``key`` being the label name, the value being the label value, even if the value is empty.
pub const k8s_statefulset_label = types.StringAttribute{
    .name = "k8s.statefulset.label",
    .brief = "The label placed on the StatefulSet, the ``key`` being the label name, the value being the label value, even if the value is empty.",
    .note = "Examples:  - A label `replicas` with value `0` SHOULD be recorded   as the `k8s.statefulset.label.app` attribute with value `\"guestbook\"`. - A label `injected` with empty string value SHOULD be recorded as   the `k8s.statefulset.label.injected` attribute with value `\"\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the StatefulSet.
pub const k8s_statefulset_name = types.StringAttribute{
    .name = "k8s.statefulset.name",
    .brief = "The name of the StatefulSet.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UID of the StatefulSet.
pub const k8s_statefulset_uid = types.StringAttribute{
    .name = "k8s.statefulset.uid",
    .brief = "The UID of the StatefulSet.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of K8s [StorageClass](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#storageclass-v1-storage-k8s-io) object.
pub const k8s_storageclass_name = types.StringAttribute{
    .name = "k8s.storageclass.name",
    .brief = "The name of K8s [StorageClass](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#storageclass-v1-storage-k8s-io) object.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the K8s volume.
pub const k8s_volume_name = types.StringAttribute{
    .name = "k8s.volume.name",
    .brief = "The name of the K8s volume.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const k8s_volume_typeValue = enum {
    persistent_volume_claim,
    config_map,
    downward_api,
    empty_dir,
    secret,
    local,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .persistent_volume_claim => "persistentVolumeClaim",
            .config_map => "configMap",
            .downward_api => "downwardAPI",
            .empty_dir => "emptyDir",
            .secret => "secret",
            .local => "local",
        };
    }
};

/// The type of the K8s volume.
pub const k8s_volume_type = types.EnumAttribute(k8s_volume_typeValue){
    .name = "k8s.volume.type",
    .brief = "The type of the K8s volume.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const linux_memory_slab_stateValue = enum {
    reclaimable,
    unreclaimable,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .reclaimable => "reclaimable",
            .unreclaimable => "unreclaimable",
        };
    }
};

/// The Linux Slab memory state
pub const linux_memory_slab_state = types.EnumAttribute(linux_memory_slab_stateValue){
    .name = "linux.memory.slab.state",
    .brief = "The Linux Slab memory state",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The basename of the file.
pub const log_file_name = types.StringAttribute{
    .name = "log.file.name",
    .brief = "The basename of the file.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The basename of the file, with symlinks resolved.
pub const log_file_name_resolved = types.StringAttribute{
    .name = "log.file.name_resolved",
    .brief = "The basename of the file, with symlinks resolved.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full path to the file.
pub const log_file_path = types.StringAttribute{
    .name = "log.file.path",
    .brief = "The full path to the file.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full path to the file, with symlinks resolved.
pub const log_file_path_resolved = types.StringAttribute{
    .name = "log.file.path_resolved",
    .brief = "The full path to the file, with symlinks resolved.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const log_iostreamValue = enum {
    stdout,
    stderr,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .stdout => "stdout",
            .stderr => "stderr",
        };
    }
};

/// The stream associated with the log. See below for a list of well-known values.
pub const log_iostream = types.EnumAttribute(log_iostreamValue){
    .name = "log.iostream",
    .brief = "The stream associated with the log. See below for a list of well-known values.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The complete original Log Record.
pub const log_record_original = types.StringAttribute{
    .name = "log.record.original",
    .brief = "The complete original Log Record.",
    .note = "This value MAY be added when processing a Log Record which was originally transmitted as a string or equivalent data type AND the Body field of the Log Record does not contain the same value. (e.g. a syslog or a log record read from a file.)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A unique identifier for the Log Record.
pub const log_record_uid = types.StringAttribute{
    .name = "log.record.uid",
    .brief = "A unique identifier for the Log Record.",
    .note = "If an id is provided, other log records with the same id will be considered duplicates and can be removed safely. This means, that two distinguishable log records MUST have different values. The id MAY be an [Universally Unique Lexicographically Sortable Identifier (ULID)](https://github.com/ulid/spec), but other identifiers (e.g. UUID) may be used as needed.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the logical partition that hosts a systems with a mainframe operating system.
pub const mainframe_lpar_name = types.StringAttribute{
    .name = "mainframe.lpar.name",
    .brief = "Name of the logical partition that hosts a systems with a mainframe operating system.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `rpc.message.compressed_size` instead.
pub const message_compressed_size = types.IntAttribute{
    .name = "message.compressed_size",
    .brief = "Deprecated, use `rpc.message.compressed_size` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `rpc.message.id` instead.
pub const message_id = types.IntAttribute{
    .name = "message.id",
    .brief = "Deprecated, use `rpc.message.id` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const message_typeValue = enum {
    sent,
    received,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .sent => "SENT",
            .received => "RECEIVED",
        };
    }
};

/// Deprecated, use `rpc.message.type` instead.
pub const message_type = types.EnumAttribute(message_typeValue){
    .name = "message.type",
    .brief = "Deprecated, use `rpc.message.type` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `rpc.message.uncompressed_size` instead.
pub const message_uncompressed_size = types.IntAttribute{
    .name = "message.uncompressed_size",
    .brief = "Deprecated, use `rpc.message.uncompressed_size` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The number of messages sent, received, or processed in the scope of the batching operation.
pub const messaging_batch_message_count = types.IntAttribute{
    .name = "messaging.batch.message_count",
    .brief = "The number of messages sent, received, or processed in the scope of the batching operation.",
    .note = "Instrumentations SHOULD NOT set `messaging.batch.message_count` on spans that operate with a single message. When a messaging client library supports both batch and single-message API for the same operation, instrumentations SHOULD use `messaging.batch.message_count` for batching APIs and SHOULD NOT use it for single-message APIs.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A unique identifier for the client that consumes or produces a message.
pub const messaging_client_id = types.StringAttribute{
    .name = "messaging.client.id",
    .brief = "A unique identifier for the client that consumes or produces a message.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the consumer group with which a consumer is associated.
pub const messaging_consumer_group_name = types.StringAttribute{
    .name = "messaging.consumer.group.name",
    .brief = "The name of the consumer group with which a consumer is associated.",
    .note = "Semantic conventions for individual messaging systems SHOULD document whether `messaging.consumer.group.name` is applicable and what it means in the context of that system.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A boolean that is true if the message destination is anonymous (could be unnamed or have auto-generated name).
pub const messaging_destination_anonymous = types.BooleanAttribute{
    .name = "messaging.destination.anonymous",
    .brief = "A boolean that is true if the message destination is anonymous (could be unnamed or have auto-generated name).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The message destination name
pub const messaging_destination_name = types.StringAttribute{
    .name = "messaging.destination.name",
    .brief = "The message destination name",
    .note = "Destination name SHOULD uniquely identify a specific queue, topic or other entity within the broker. If the broker doesn't have such notion, the destination name SHOULD uniquely identify the broker.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The identifier of the partition messages are sent to or received from, unique within the `messaging.destination.name`.
pub const messaging_destination_partition_id = types.StringAttribute{
    .name = "messaging.destination.partition.id",
    .brief = "The identifier of the partition messages are sent to or received from, unique within the `messaging.destination.name`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the destination subscription from which a message is consumed.
pub const messaging_destination_subscription_name = types.StringAttribute{
    .name = "messaging.destination.subscription.name",
    .brief = "The name of the destination subscription from which a message is consumed.",
    .note = "Semantic conventions for individual messaging systems SHOULD document whether `messaging.destination.subscription.name` is applicable and what it means in the context of that system.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Low cardinality representation of the messaging destination name
pub const messaging_destination_template = types.StringAttribute{
    .name = "messaging.destination.template",
    .brief = "Low cardinality representation of the messaging destination name",
    .note = "Destination names could be constructed from templates. An example would be a destination name involving a user name or product id. Although the destination name in this case is of high cardinality, the underlying template is of low cardinality and can be effectively used for grouping and aggregation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A boolean that is true if the message destination is temporary and might not exist anymore after messages are processed.
pub const messaging_destination_temporary = types.BooleanAttribute{
    .name = "messaging.destination.temporary",
    .brief = "A boolean that is true if the message destination is temporary and might not exist anymore after messages are processed.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, no replacement at this time.
pub const messaging_destination_publish_anonymous = types.BooleanAttribute{
    .name = "messaging.destination_publish.anonymous",
    .brief = "Deprecated, no replacement at this time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, no replacement at this time.
pub const messaging_destination_publish_name = types.StringAttribute{
    .name = "messaging.destination_publish.name",
    .brief = "Deprecated, no replacement at this time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `messaging.consumer.group.name` instead.
pub const messaging_eventhubs_consumer_group = types.StringAttribute{
    .name = "messaging.eventhubs.consumer.group",
    .brief = "Deprecated, use `messaging.consumer.group.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UTC epoch seconds at which the message has been accepted and stored in the entity.
pub const messaging_eventhubs_message_enqueued_time = types.IntAttribute{
    .name = "messaging.eventhubs.message.enqueued_time",
    .brief = "The UTC epoch seconds at which the message has been accepted and stored in the entity.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ack deadline in seconds set for the modify ack deadline request.
pub const messaging_gcp_pubsub_message_ack_deadline = types.IntAttribute{
    .name = "messaging.gcp_pubsub.message.ack_deadline",
    .brief = "The ack deadline in seconds set for the modify ack deadline request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ack id for a given message.
pub const messaging_gcp_pubsub_message_ack_id = types.StringAttribute{
    .name = "messaging.gcp_pubsub.message.ack_id",
    .brief = "The ack id for a given message.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The delivery attempt for a given message.
pub const messaging_gcp_pubsub_message_delivery_attempt = types.IntAttribute{
    .name = "messaging.gcp_pubsub.message.delivery_attempt",
    .brief = "The delivery attempt for a given message.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ordering key for a given message. If the attribute is not present, the message does not have an ordering key.
pub const messaging_gcp_pubsub_message_ordering_key = types.StringAttribute{
    .name = "messaging.gcp_pubsub.message.ordering_key",
    .brief = "The ordering key for a given message. If the attribute is not present, the message does not have an ordering key.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `messaging.consumer.group.name` instead.
pub const messaging_kafka_consumer_group = types.StringAttribute{
    .name = "messaging.kafka.consumer.group",
    .brief = "Deprecated, use `messaging.consumer.group.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `messaging.destination.partition.id` instead.
pub const messaging_kafka_destination_partition = types.IntAttribute{
    .name = "messaging.kafka.destination.partition",
    .brief = "Deprecated, use `messaging.destination.partition.id` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Message keys in Kafka are used for grouping alike messages to ensure they're processed on the same partition. They differ from `messaging.message.id` in that they're not unique. If the key is `null`, the attribute MUST NOT be set.
pub const messaging_kafka_message_key = types.StringAttribute{
    .name = "messaging.kafka.message.key",
    .brief = "Message keys in Kafka are used for grouping alike messages to ensure they're processed on the same partition. They differ from `messaging.message.id` in that they're not unique. If the key is `null`, the attribute MUST NOT be set.",
    .note = "If the key type is not string, it's string representation has to be supplied for the attribute. If the key has no unambiguous, canonical string form, don't include its value.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `messaging.kafka.offset` instead.
pub const messaging_kafka_message_offset = types.IntAttribute{
    .name = "messaging.kafka.message.offset",
    .brief = "Deprecated, use `messaging.kafka.offset` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A boolean that is true if the message is a tombstone.
pub const messaging_kafka_message_tombstone = types.BooleanAttribute{
    .name = "messaging.kafka.message.tombstone",
    .brief = "A boolean that is true if the message is a tombstone.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The offset of a record in the corresponding Kafka partition.
pub const messaging_kafka_offset = types.IntAttribute{
    .name = "messaging.kafka.offset",
    .brief = "The offset of a record in the corresponding Kafka partition.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The size of the message body in bytes.
pub const messaging_message_body_size = types.IntAttribute{
    .name = "messaging.message.body.size",
    .brief = "The size of the message body in bytes.",
    .note = "This can refer to both the compressed or uncompressed body size. If both sizes are known, the uncompressed body size should be used.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The conversation ID identifying the conversation to which the message belongs, represented as a string. Sometimes called "Correlation ID".
pub const messaging_message_conversation_id = types.StringAttribute{
    .name = "messaging.message.conversation_id",
    .brief = "The conversation ID identifying the conversation to which the message belongs, represented as a string. Sometimes called \"Correlation ID\".",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The size of the message body and metadata in bytes.
pub const messaging_message_envelope_size = types.IntAttribute{
    .name = "messaging.message.envelope.size",
    .brief = "The size of the message body and metadata in bytes.",
    .note = "This can refer to both the compressed or uncompressed size. If both sizes are known, the uncompressed size should be used.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A value used by the messaging system as an identifier for the message, represented as a string.
pub const messaging_message_id = types.StringAttribute{
    .name = "messaging.message.id",
    .brief = "A value used by the messaging system as an identifier for the message, represented as a string.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `messaging.operation.type` instead.
pub const messaging_operation = types.StringAttribute{
    .name = "messaging.operation",
    .brief = "Deprecated, use `messaging.operation.type` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The system-specific name of the messaging operation.
pub const messaging_operation_name = types.StringAttribute{
    .name = "messaging.operation.name",
    .brief = "The system-specific name of the messaging operation.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const messaging_operation_typeValue = enum {
    create,
    send,
    receive,
    process,
    settle,
    deliver,
    publish,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .create => "create",
            .send => "send",
            .receive => "receive",
            .process => "process",
            .settle => "settle",
            .deliver => "deliver",
            .publish => "publish",
        };
    }
};

/// A string identifying the type of the messaging operation.
pub const messaging_operation_type = types.EnumAttribute(messaging_operation_typeValue){
    .name = "messaging.operation.type",
    .brief = "A string identifying the type of the messaging operation.",
    .note = "If a custom value is used, it MUST be of low cardinality.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// RabbitMQ message routing key.
pub const messaging_rabbitmq_destination_routing_key = types.StringAttribute{
    .name = "messaging.rabbitmq.destination.routing_key",
    .brief = "RabbitMQ message routing key.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// RabbitMQ message delivery tag
pub const messaging_rabbitmq_message_delivery_tag = types.IntAttribute{
    .name = "messaging.rabbitmq.message.delivery_tag",
    .brief = "RabbitMQ message delivery tag",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `messaging.consumer.group.name` instead.
pub const messaging_rocketmq_client_group = types.StringAttribute{
    .name = "messaging.rocketmq.client_group",
    .brief = "Deprecated, use `messaging.consumer.group.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const messaging_rocketmq_consumption_modelValue = enum {
    clustering,
    broadcasting,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .clustering => "clustering",
            .broadcasting => "broadcasting",
        };
    }
};

/// Model of message consumption. This only applies to consumer spans.
pub const messaging_rocketmq_consumption_model = types.EnumAttribute(messaging_rocketmq_consumption_modelValue){
    .name = "messaging.rocketmq.consumption_model",
    .brief = "Model of message consumption. This only applies to consumer spans.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The delay time level for delay message, which determines the message delay time.
pub const messaging_rocketmq_message_delay_time_level = types.IntAttribute{
    .name = "messaging.rocketmq.message.delay_time_level",
    .brief = "The delay time level for delay message, which determines the message delay time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The timestamp in milliseconds that the delay message is expected to be delivered to consumer.
pub const messaging_rocketmq_message_delivery_timestamp = types.IntAttribute{
    .name = "messaging.rocketmq.message.delivery_timestamp",
    .brief = "The timestamp in milliseconds that the delay message is expected to be delivered to consumer.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// It is essential for FIFO message. Messages that belong to the same message group are always processed one by one within the same consumer group.
pub const messaging_rocketmq_message_group = types.StringAttribute{
    .name = "messaging.rocketmq.message.group",
    .brief = "It is essential for FIFO message. Messages that belong to the same message group are always processed one by one within the same consumer group.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Key(s) of message, another way to mark message besides message id.
pub const messaging_rocketmq_message_keys = types.StringArrayAttribute{
    .name = "messaging.rocketmq.message.keys",
    .brief = "Key(s) of message, another way to mark message besides message id.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The secondary classifier of message besides topic.
pub const messaging_rocketmq_message_tag = types.StringAttribute{
    .name = "messaging.rocketmq.message.tag",
    .brief = "The secondary classifier of message besides topic.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const messaging_rocketmq_message_typeValue = enum {
    normal,
    fifo,
    delay,
    transaction,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .normal => "normal",
            .fifo => "fifo",
            .delay => "delay",
            .transaction => "transaction",
        };
    }
};

/// Type of message.
pub const messaging_rocketmq_message_type = types.EnumAttribute(messaging_rocketmq_message_typeValue){
    .name = "messaging.rocketmq.message.type",
    .brief = "Type of message.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Namespace of RocketMQ resources, resources in different namespaces are individual.
pub const messaging_rocketmq_namespace = types.StringAttribute{
    .name = "messaging.rocketmq.namespace",
    .brief = "Namespace of RocketMQ resources, resources in different namespaces are individual.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `messaging.destination.subscription.name` instead.
pub const messaging_servicebus_destination_subscription_name = types.StringAttribute{
    .name = "messaging.servicebus.destination.subscription_name",
    .brief = "Deprecated, use `messaging.destination.subscription.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const messaging_servicebus_disposition_statusValue = enum {
    complete,
    abandon,
    dead_letter,
    @"defer",
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .complete => "complete",
            .abandon => "abandon",
            .dead_letter => "dead_letter",
            .@"defer" => "defer",
        };
    }
};

/// Describes the [settlement type](https://learn.microsoft.com/azure/service-bus-messaging/message-transfers-locks-settlement#peeklock).
pub const messaging_servicebus_disposition_status = types.EnumAttribute(messaging_servicebus_disposition_statusValue){
    .name = "messaging.servicebus.disposition_status",
    .brief = "Describes the [settlement type](https://learn.microsoft.com/azure/service-bus-messaging/message-transfers-locks-settlement#peeklock).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Number of deliveries that have been attempted for this message.
pub const messaging_servicebus_message_delivery_count = types.IntAttribute{
    .name = "messaging.servicebus.message.delivery_count",
    .brief = "Number of deliveries that have been attempted for this message.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The UTC epoch seconds at which the message has been accepted and stored in the entity.
pub const messaging_servicebus_message_enqueued_time = types.IntAttribute{
    .name = "messaging.servicebus.message.enqueued_time",
    .brief = "The UTC epoch seconds at which the message has been accepted and stored in the entity.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const messaging_systemValue = enum {
    activemq,
    aws_sqs,
    eventgrid,
    eventhubs,
    servicebus,
    gcp_pubsub,
    jms,
    kafka,
    rabbitmq,
    rocketmq,
    pulsar,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .activemq => "activemq",
            .aws_sqs => "aws_sqs",
            .eventgrid => "eventgrid",
            .eventhubs => "eventhubs",
            .servicebus => "servicebus",
            .gcp_pubsub => "gcp_pubsub",
            .jms => "jms",
            .kafka => "kafka",
            .rabbitmq => "rabbitmq",
            .rocketmq => "rocketmq",
            .pulsar => "pulsar",
        };
    }
};

/// The messaging system as identified by the client instrumentation.
pub const messaging_system = types.EnumAttribute(messaging_systemValue){
    .name = "messaging.system",
    .brief = "The messaging system as identified by the client instrumentation.",
    .note = "The actual messaging system may differ from the one known by the client. For example, when using Kafka client libraries to communicate with Azure Event Hubs, the `messaging.system` is set to `kafka` based on the instrumentation's best knowledge.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.local.address`.
pub const net_host_ip = types.StringAttribute{
    .name = "net.host.ip",
    .brief = "Deprecated, use `network.local.address`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `server.address`.
pub const net_host_name = types.StringAttribute{
    .name = "net.host.name",
    .brief = "Deprecated, use `server.address`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `server.port`.
pub const net_host_port = types.IntAttribute{
    .name = "net.host.port",
    .brief = "Deprecated, use `server.port`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.peer.address`.
pub const net_peer_ip = types.StringAttribute{
    .name = "net.peer.ip",
    .brief = "Deprecated, use `network.peer.address`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `server.address` on client spans and `client.address` on server spans.
pub const net_peer_name = types.StringAttribute{
    .name = "net.peer.name",
    .brief = "Deprecated, use `server.address` on client spans and `client.address` on server spans.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `server.port` on client spans and `client.port` on server spans.
pub const net_peer_port = types.IntAttribute{
    .name = "net.peer.port",
    .brief = "Deprecated, use `server.port` on client spans and `client.port` on server spans.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.protocol.name`.
pub const net_protocol_name = types.StringAttribute{
    .name = "net.protocol.name",
    .brief = "Deprecated, use `network.protocol.name`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.protocol.version`.
pub const net_protocol_version = types.StringAttribute{
    .name = "net.protocol.version",
    .brief = "Deprecated, use `network.protocol.version`.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const net_sock_familyValue = enum {
    inet,
    inet6,
    unix,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .inet => "inet",
            .inet6 => "inet6",
            .unix => "unix",
        };
    }
};

/// Deprecated, use `network.transport` and `network.type`.
pub const net_sock_family = types.EnumAttribute(net_sock_familyValue){
    .name = "net.sock.family",
    .brief = "Deprecated, use `network.transport` and `network.type`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.local.address`.
pub const net_sock_host_addr = types.StringAttribute{
    .name = "net.sock.host.addr",
    .brief = "Deprecated, use `network.local.address`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.local.port`.
pub const net_sock_host_port = types.IntAttribute{
    .name = "net.sock.host.port",
    .brief = "Deprecated, use `network.local.port`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.peer.address`.
pub const net_sock_peer_addr = types.StringAttribute{
    .name = "net.sock.peer.addr",
    .brief = "Deprecated, use `network.peer.address`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, no replacement at this time.
pub const net_sock_peer_name = types.StringAttribute{
    .name = "net.sock.peer.name",
    .brief = "Deprecated, no replacement at this time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `network.peer.port`.
pub const net_sock_peer_port = types.IntAttribute{
    .name = "net.sock.peer.port",
    .brief = "Deprecated, use `network.peer.port`.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const net_transportValue = enum {
    ip_tcp,
    ip_udp,
    pipe,
    inproc,
    other,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .ip_tcp => "ip_tcp",
            .ip_udp => "ip_udp",
            .pipe => "pipe",
            .inproc => "inproc",
            .other => "other",
        };
    }
};

/// Deprecated, use `network.transport`.
pub const net_transport = types.EnumAttribute(net_transportValue){
    .name = "net.transport",
    .brief = "Deprecated, use `network.transport`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ISO 3166-1 alpha-2 2-character country code associated with the mobile carrier network.
pub const network_carrier_icc = types.StringAttribute{
    .name = "network.carrier.icc",
    .brief = "The ISO 3166-1 alpha-2 2-character country code associated with the mobile carrier network.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The mobile carrier country code.
pub const network_carrier_mcc = types.StringAttribute{
    .name = "network.carrier.mcc",
    .brief = "The mobile carrier country code.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The mobile carrier network code.
pub const network_carrier_mnc = types.StringAttribute{
    .name = "network.carrier.mnc",
    .brief = "The mobile carrier network code.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the mobile carrier.
pub const network_carrier_name = types.StringAttribute{
    .name = "network.carrier.name",
    .brief = "The name of the mobile carrier.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const network_connection_stateValue = enum {
    closed,
    close_wait,
    closing,
    established,
    fin_wait_1,
    fin_wait_2,
    last_ack,
    listen,
    syn_received,
    syn_sent,
    time_wait,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .closed => "closed",
            .close_wait => "close_wait",
            .closing => "closing",
            .established => "established",
            .fin_wait_1 => "fin_wait_1",
            .fin_wait_2 => "fin_wait_2",
            .last_ack => "last_ack",
            .listen => "listen",
            .syn_received => "syn_received",
            .syn_sent => "syn_sent",
            .time_wait => "time_wait",
        };
    }
};

/// The state of network connection
pub const network_connection_state = types.EnumAttribute(network_connection_stateValue){
    .name = "network.connection.state",
    .brief = "The state of network connection",
    .note = "Connection states are defined as part of the [rfc9293](https://datatracker.ietf.org/doc/html/rfc9293#section-3.3.2)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const network_connection_subtypeValue = enum {
    gprs,
    edge,
    umts,
    cdma,
    evdo_0,
    evdo_a,
    cdma2000_1xrtt,
    hsdpa,
    hsupa,
    hspa,
    iden,
    evdo_b,
    lte,
    ehrpd,
    hspap,
    gsm,
    td_scdma,
    iwlan,
    nr,
    nrnsa,
    lte_ca,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .gprs => "gprs",
            .edge => "edge",
            .umts => "umts",
            .cdma => "cdma",
            .evdo_0 => "evdo_0",
            .evdo_a => "evdo_a",
            .cdma2000_1xrtt => "cdma2000_1xrtt",
            .hsdpa => "hsdpa",
            .hsupa => "hsupa",
            .hspa => "hspa",
            .iden => "iden",
            .evdo_b => "evdo_b",
            .lte => "lte",
            .ehrpd => "ehrpd",
            .hspap => "hspap",
            .gsm => "gsm",
            .td_scdma => "td_scdma",
            .iwlan => "iwlan",
            .nr => "nr",
            .nrnsa => "nrnsa",
            .lte_ca => "lte_ca",
        };
    }
};

/// This describes more details regarding the connection.type. It may be the type of cell technology connection, but it could be used for describing details about a wifi connection.
pub const network_connection_subtype = types.EnumAttribute(network_connection_subtypeValue){
    .name = "network.connection.subtype",
    .brief = "This describes more details regarding the connection.type. It may be the type of cell technology connection, but it could be used for describing details about a wifi connection.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const network_connection_typeValue = enum {
    wifi,
    wired,
    cell,
    unavailable,
    unknown,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .wifi => "wifi",
            .wired => "wired",
            .cell => "cell",
            .unavailable => "unavailable",
            .unknown => "unknown",
        };
    }
};

/// The internet connection type.
pub const network_connection_type = types.EnumAttribute(network_connection_typeValue){
    .name = "network.connection.type",
    .brief = "The internet connection type.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The network interface name.
pub const network_interface_name = types.StringAttribute{
    .name = "network.interface.name",
    .brief = "The network interface name.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const network_io_directionValue = enum {
    transmit,
    receive,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .transmit => "transmit",
            .receive => "receive",
        };
    }
};

/// The network IO operation direction.
pub const network_io_direction = types.EnumAttribute(network_io_directionValue){
    .name = "network.io.direction",
    .brief = "The network IO operation direction.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Local address of the network connection - IP address or Unix domain socket name.
pub const network_local_address = types.StringAttribute{
    .name = "network.local.address",
    .brief = "Local address of the network connection - IP address or Unix domain socket name.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Local port number of the network connection.
pub const network_local_port = types.IntAttribute{
    .name = "network.local.port",
    .brief = "Local port number of the network connection.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Peer address of the network connection - IP address or Unix domain socket name.
pub const network_peer_address = types.StringAttribute{
    .name = "network.peer.address",
    .brief = "Peer address of the network connection - IP address or Unix domain socket name.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Peer port number of the network connection.
pub const network_peer_port = types.IntAttribute{
    .name = "network.peer.port",
    .brief = "Peer port number of the network connection.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// [OSI application layer](https://wikipedia.org/wiki/Application_layer) or non-OSI equivalent.
pub const network_protocol_name = types.StringAttribute{
    .name = "network.protocol.name",
    .brief = "[OSI application layer](https://wikipedia.org/wiki/Application_layer) or non-OSI equivalent.",
    .note = "The value SHOULD be normalized to lowercase.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The actual version of the protocol used for network communication.
pub const network_protocol_version = types.StringAttribute{
    .name = "network.protocol.version",
    .brief = "The actual version of the protocol used for network communication.",
    .note = "If protocol version is subject to negotiation (for example using [ALPN](https://www.rfc-editor.org/rfc/rfc7301.html)), this attribute SHOULD be set to the negotiated version. If the actual protocol version is not known, this attribute SHOULD NOT be set.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const network_transportValue = enum {
    tcp,
    udp,
    pipe,
    unix,
    quic,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .tcp => "tcp",
            .udp => "udp",
            .pipe => "pipe",
            .unix => "unix",
            .quic => "quic",
        };
    }
};

/// [OSI transport layer](https://wikipedia.org/wiki/Transport_layer) or [inter-process communication method](https://wikipedia.org/wiki/Inter-process_communication).
pub const network_transport = types.EnumAttribute(network_transportValue){
    .name = "network.transport",
    .brief = "[OSI transport layer](https://wikipedia.org/wiki/Transport_layer) or [inter-process communication method](https://wikipedia.org/wiki/Inter-process_communication).",
    .note = "The value SHOULD be normalized to lowercase.  Consider always setting the transport when setting a port number, since a port number is ambiguous without knowing the transport. For example different processes could be listening on TCP port 12345 and UDP port 12345.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const network_typeValue = enum {
    ipv4,
    ipv6,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .ipv4 => "ipv4",
            .ipv6 => "ipv6",
        };
    }
};

/// [OSI network layer](https://wikipedia.org/wiki/Network_layer) or non-OSI equivalent.
pub const network_type = types.EnumAttribute(network_typeValue){
    .name = "network.type",
    .brief = "[OSI network layer](https://wikipedia.org/wiki/Network_layer) or non-OSI equivalent.",
    .note = "The value SHOULD be normalized to lowercase.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const nodejs_eventloop_stateValue = enum {
    active,
    idle,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .active => "active",
            .idle => "idle",
        };
    }
};

/// The state of event loop time.
pub const nodejs_eventloop_state = types.EnumAttribute(nodejs_eventloop_stateValue){
    .name = "nodejs.eventloop.state",
    .brief = "The state of event loop time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The digest of the OCI image manifest. For container images specifically is the digest by which the container image is known.
pub const oci_manifest_digest = types.StringAttribute{
    .name = "oci.manifest.digest",
    .brief = "The digest of the OCI image manifest. For container images specifically is the digest by which the container image is known.",
    .note = "Follows [OCI Image Manifest Specification](https://github.com/opencontainers/image-spec/blob/main/manifest.md), and specifically the [Digest property](https://github.com/opencontainers/image-spec/blob/main/descriptor.md#digests). An example can be found in [Example Image Manifest](https://github.com/opencontainers/image-spec/blob/main/manifest.md#example-image-manifest).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const opentracing_ref_typeValue = enum {
    child_of,
    follows_from,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .child_of => "child_of",
            .follows_from => "follows_from",
        };
    }
};

/// Parent-child Reference type
pub const opentracing_ref_type = types.EnumAttribute(opentracing_ref_typeValue){
    .name = "opentracing.ref_type",
    .brief = "Parent-child Reference type",
    .note = "The causal relationship between a child Span and a parent Span.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Unique identifier for a particular build or compilation of the operating system.
pub const os_build_id = types.StringAttribute{
    .name = "os.build_id",
    .brief = "Unique identifier for a particular build or compilation of the operating system.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Human readable (not intended to be parsed) OS version information, like e.g. reported by `ver` or `lsb_release -a` commands.
pub const os_description = types.StringAttribute{
    .name = "os.description",
    .brief = "Human readable (not intended to be parsed) OS version information, like e.g. reported by `ver` or `lsb_release -a` commands.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Human readable operating system name.
pub const os_name = types.StringAttribute{
    .name = "os.name",
    .brief = "Human readable operating system name.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const os_typeValue = enum {
    windows,
    linux,
    darwin,
    freebsd,
    netbsd,
    openbsd,
    dragonflybsd,
    hpux,
    aix,
    solaris,
    z_os,
    zos,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .windows => "windows",
            .linux => "linux",
            .darwin => "darwin",
            .freebsd => "freebsd",
            .netbsd => "netbsd",
            .openbsd => "openbsd",
            .dragonflybsd => "dragonflybsd",
            .hpux => "hpux",
            .aix => "aix",
            .solaris => "solaris",
            .z_os => "z_os",
            .zos => "zos",
        };
    }
};

/// The operating system type.
pub const os_type = types.EnumAttribute(os_typeValue){
    .name = "os.type",
    .brief = "The operating system type.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version string of the operating system as defined in [Version Attributes](/docs/resource/README.md#version-attributes).
pub const os_version = types.StringAttribute{
    .name = "os.version",
    .brief = "The version string of the operating system as defined in [Version Attributes](/docs/resource/README.md#version-attributes).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A name uniquely identifying the instance of the OpenTelemetry component within its containing SDK instance.
pub const otel_component_name = types.StringAttribute{
    .name = "otel.component.name",
    .brief = "A name uniquely identifying the instance of the OpenTelemetry component within its containing SDK instance.",
    .note = "Implementations SHOULD ensure a low cardinality for this attribute, even across application or SDK restarts. E.g. implementations MUST NOT use UUIDs as values for this attribute.  Implementations MAY achieve these goals by following a `[otel.component.type]/[instance-counter]` pattern, e.g. `batching_span_processor/0`. Hereby `otel.component.type` refers to the corresponding attribute value of the component.  The value of `instance-counter` MAY be automatically assigned by the component and uniqueness within the enclosing SDK instance MUST be guaranteed. For example, `[instance-counter]` MAY be implemented by using a monotonically increasing counter (starting with `0`), which is incremented every time an instance of the given component type is started.  With this implementation, for example the first Batching Span Processor would have `batching_span_processor/0` as `otel.component.name`, the second one `batching_span_processor/1` and so on. These values will therefore be reused in the case of an application restart.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const otel_component_typeValue = enum {
    batching_span_processor,
    simple_span_processor,
    batching_log_processor,
    simple_log_processor,
    otlp_grpc_span_exporter,
    otlp_http_span_exporter,
    otlp_http_json_span_exporter,
    zipkin_http_span_exporter,
    otlp_grpc_log_exporter,
    otlp_http_log_exporter,
    otlp_http_json_log_exporter,
    periodic_metric_reader,
    otlp_grpc_metric_exporter,
    otlp_http_metric_exporter,
    otlp_http_json_metric_exporter,
    prometheus_http_text_metric_exporter,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .batching_span_processor => "batching_span_processor",
            .simple_span_processor => "simple_span_processor",
            .batching_log_processor => "batching_log_processor",
            .simple_log_processor => "simple_log_processor",
            .otlp_grpc_span_exporter => "otlp_grpc_span_exporter",
            .otlp_http_span_exporter => "otlp_http_span_exporter",
            .otlp_http_json_span_exporter => "otlp_http_json_span_exporter",
            .zipkin_http_span_exporter => "zipkin_http_span_exporter",
            .otlp_grpc_log_exporter => "otlp_grpc_log_exporter",
            .otlp_http_log_exporter => "otlp_http_log_exporter",
            .otlp_http_json_log_exporter => "otlp_http_json_log_exporter",
            .periodic_metric_reader => "periodic_metric_reader",
            .otlp_grpc_metric_exporter => "otlp_grpc_metric_exporter",
            .otlp_http_metric_exporter => "otlp_http_metric_exporter",
            .otlp_http_json_metric_exporter => "otlp_http_json_metric_exporter",
            .prometheus_http_text_metric_exporter => "prometheus_http_text_metric_exporter",
        };
    }
};

/// A name identifying the type of the OpenTelemetry component.
pub const otel_component_type = types.EnumAttribute(otel_component_typeValue){
    .name = "otel.component.type",
    .brief = "A name identifying the type of the OpenTelemetry component.",
    .note = "If none of the standardized values apply, implementations SHOULD use the language-defined name of the type. E.g. for Java the fully qualified classname SHOULD be used in this case.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated. Use the `otel.scope.name` attribute
pub const otel_library_name = types.StringAttribute{
    .name = "otel.library.name",
    .brief = "Deprecated. Use the `otel.scope.name` attribute",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated. Use the `otel.scope.version` attribute.
pub const otel_library_version = types.StringAttribute{
    .name = "otel.library.version",
    .brief = "Deprecated. Use the `otel.scope.version` attribute.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the instrumentation scope - (`InstrumentationScope.Name` in OTLP).
pub const otel_scope_name = types.StringAttribute{
    .name = "otel.scope.name",
    .brief = "The name of the instrumentation scope - (`InstrumentationScope.Name` in OTLP).",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The version of the instrumentation scope - (`InstrumentationScope.Version` in OTLP).
pub const otel_scope_version = types.StringAttribute{
    .name = "otel.scope.version",
    .brief = "The version of the instrumentation scope - (`InstrumentationScope.Version` in OTLP).",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const otel_span_parent_originValue = enum {
    none,
    local,
    remote,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .none => "none",
            .local => "local",
            .remote => "remote",
        };
    }
};

/// Determines whether the span has a parent span, and if so, [whether it is a remote parent](https://opentelemetry.io/docs/specs/otel/trace/api/#isremote)
pub const otel_span_parent_origin = types.EnumAttribute(otel_span_parent_originValue){
    .name = "otel.span.parent.origin",
    .brief = "Determines whether the span has a parent span, and if so, [whether it is a remote parent](https://opentelemetry.io/docs/specs/otel/trace/api/#isremote)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const otel_span_sampling_resultValue = enum {
    drop,
    record_only,
    record_and_sample,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .drop => "DROP",
            .record_only => "RECORD_ONLY",
            .record_and_sample => "RECORD_AND_SAMPLE",
        };
    }
};

/// The result value of the sampler for this span
pub const otel_span_sampling_result = types.EnumAttribute(otel_span_sampling_resultValue){
    .name = "otel.span.sampling_result",
    .brief = "The result value of the sampler for this span",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const otel_status_codeValue = enum {
    ok,
    @"error",
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .ok => "OK",
            .@"error" => "ERROR",
        };
    }
};

/// Name of the code, either "OK" or "ERROR". MUST NOT be set if the status code is UNSET.
pub const otel_status_code = types.EnumAttribute(otel_status_codeValue){
    .name = "otel.status_code",
    .brief = "Name of the code, either \"OK\" or \"ERROR\". MUST NOT be set if the status code is UNSET.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Description of the Status if it has a value, otherwise not set.
pub const otel_status_description = types.StringAttribute{
    .name = "otel.status_description",
    .brief = "Description of the Status if it has a value, otherwise not set.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const stateValue = enum {
    idle,
    used,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .idle => "idle",
            .used => "used",
        };
    }
};

/// Deprecated, use `db.client.connection.state` instead.
pub const state = types.EnumAttribute(stateValue){
    .name = "state",
    .brief = "Deprecated, use `db.client.connection.state` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [`service.name`](/docs/resource/README.md#service) of the remote service. SHOULD be equal to the actual `service.name` resource attribute of the remote service if any.
pub const peer_service = types.StringAttribute{
    .name = "peer.service",
    .brief = "The [`service.name`](/docs/resource/README.md#service) of the remote service. SHOULD be equal to the actual `service.name` resource attribute of the remote service if any.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `db.client.connection.pool.name` instead.
pub const pool_name = types.StringAttribute{
    .name = "pool.name",
    .brief = "Deprecated, use `db.client.connection.pool.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Length of the process.command_args array
pub const process_args_count = types.IntAttribute{
    .name = "process.args_count",
    .brief = "Length of the process.command_args array",
    .note = "This field can be useful for querying or performing bucket analysis on how many arguments were provided to start a process. More arguments may be an indication of suspicious activity.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The command used to launch the process (i.e. the command name). On Linux based systems, can be set to the zeroth string in `proc/[pid]/cmdline`. On Windows, can be set to the first parameter extracted from `GetCommandLineW`.
pub const process_command = types.StringAttribute{
    .name = "process.command",
    .brief = "The command used to launch the process (i.e. the command name). On Linux based systems, can be set to the zeroth string in `proc/[pid]/cmdline`. On Windows, can be set to the first parameter extracted from `GetCommandLineW`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// All the command arguments (including the command/executable itself) as received by the process. On Linux-based systems (and some other Unixoid systems supporting procfs), can be set according to the list of null-delimited strings extracted from `proc/[pid]/cmdline`. For libc-based executables, this would be the full argv vector passed to `main`. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.
pub const process_command_args = types.StringArrayAttribute{
    .name = "process.command_args",
    .brief = "All the command arguments (including the command/executable itself) as received by the process. On Linux-based systems (and some other Unixoid systems supporting procfs), can be set according to the list of null-delimited strings extracted from `proc/[pid]/cmdline`. For libc-based executables, this would be the full argv vector passed to `main`. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full command used to launch the process as a single string representing the full command. On Windows, can be set to the result of `GetCommandLineW`. Do not set this if you have to assemble it just for monitoring; use `process.command_args` instead. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.
pub const process_command_line = types.StringAttribute{
    .name = "process.command_line",
    .brief = "The full command used to launch the process as a single string representing the full command. On Windows, can be set to the result of `GetCommandLineW`. Do not set this if you have to assemble it just for monitoring; use `process.command_args` instead. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const process_context_switch_typeValue = enum {
    voluntary,
    involuntary,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .voluntary => "voluntary",
            .involuntary => "involuntary",
        };
    }
};

/// Specifies whether the context switches for this data point were voluntary or involuntary.
pub const process_context_switch_type = types.EnumAttribute(process_context_switch_typeValue){
    .name = "process.context_switch_type",
    .brief = "Specifies whether the context switches for this data point were voluntary or involuntary.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const process_cpu_stateValue = enum {
    system,
    user,
    wait,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .system => "system",
            .user => "user",
            .wait => "wait",
        };
    }
};

/// Deprecated, use `cpu.mode` instead.
pub const process_cpu_state = types.EnumAttribute(process_cpu_stateValue){
    .name = "process.cpu.state",
    .brief = "Deprecated, use `cpu.mode` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The date and time the process was created, in ISO 8601 format.
pub const process_creation_time = types.StringAttribute{
    .name = "process.creation.time",
    .brief = "The date and time the process was created, in ISO 8601 format.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Process environment variables, ``key`` being the environment variable name, the value being the environment variable value.
pub const process_environment_variable = types.StringAttribute{
    .name = "process.environment_variable",
    .brief = "Process environment variables, ``key`` being the environment variable name, the value being the environment variable value.",
    .note = "Examples:  - an environment variable `USER` with value `\"ubuntu\"` SHOULD be recorded as the `process.environment_variable.USER` attribute with value `\"ubuntu\"`.  - an environment variable `PATH` with value `\"/usr/local/bin:/usr/bin\"` SHOULD be recorded as the `process.environment_variable.PATH` attribute with value `\"/usr/local/bin:/usr/bin\"`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The GNU build ID as found in the `.note.gnu.build-id` ELF section (hex string).
pub const process_executable_build_id_gnu = types.StringAttribute{
    .name = "process.executable.build_id.gnu",
    .brief = "The GNU build ID as found in the `.note.gnu.build-id` ELF section (hex string).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The Go build ID as retrieved by `go tool buildid <go executable>`.
pub const process_executable_build_id_go = types.StringAttribute{
    .name = "process.executable.build_id.go",
    .brief = "The Go build ID as retrieved by `go tool buildid <go executable>`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Profiling specific build ID for executables. See the OTel specification for Profiles for more information.
pub const process_executable_build_id_htlhash = types.StringAttribute{
    .name = "process.executable.build_id.htlhash",
    .brief = "Profiling specific build ID for executables. See the OTel specification for Profiles for more information.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// "Deprecated, use `process.executable.build_id.htlhash` instead."
pub const process_executable_build_id_profiling = types.StringAttribute{
    .name = "process.executable.build_id.profiling",
    .brief = "\"Deprecated, use `process.executable.build_id.htlhash` instead.\"",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the process executable. On Linux based systems, this SHOULD be set to the base name of the target of `/proc/[pid]/exe`. On Windows, this SHOULD be set to the base name of `GetProcessImageFileNameW`.
pub const process_executable_name = types.StringAttribute{
    .name = "process.executable.name",
    .brief = "The name of the process executable. On Linux based systems, this SHOULD be set to the base name of the target of `/proc/[pid]/exe`. On Windows, this SHOULD be set to the base name of `GetProcessImageFileNameW`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full path to the process executable. On Linux based systems, can be set to the target of `proc/[pid]/exe`. On Windows, can be set to the result of `GetProcessImageFileNameW`.
pub const process_executable_path = types.StringAttribute{
    .name = "process.executable.path",
    .brief = "The full path to the process executable. On Linux based systems, can be set to the target of `proc/[pid]/exe`. On Windows, can be set to the result of `GetProcessImageFileNameW`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The exit code of the process.
pub const process_exit_code = types.IntAttribute{
    .name = "process.exit.code",
    .brief = "The exit code of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The date and time the process exited, in ISO 8601 format.
pub const process_exit_time = types.StringAttribute{
    .name = "process.exit.time",
    .brief = "The date and time the process exited, in ISO 8601 format.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The PID of the process's group leader. This is also the process group ID (PGID) of the process.
pub const process_group_leader_pid = types.IntAttribute{
    .name = "process.group_leader.pid",
    .brief = "The PID of the process's group leader. This is also the process group ID (PGID) of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Whether the process is connected to an interactive shell.
pub const process_interactive = types.BooleanAttribute{
    .name = "process.interactive",
    .brief = "Whether the process is connected to an interactive shell.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The control group associated with the process.
pub const process_linux_cgroup = types.StringAttribute{
    .name = "process.linux.cgroup",
    .brief = "The control group associated with the process.",
    .note = "Control groups (cgroups) are a kernel feature used to organize and manage process resources. This attribute provides the path(s) to the cgroup(s) associated with the process, which should match the contents of the [/proc/\\[PID\\]/cgroup](https://man7.org/linux/man-pages/man7/cgroups.7.html) file.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The username of the user that owns the process.
pub const process_owner = types.StringAttribute{
    .name = "process.owner",
    .brief = "The username of the user that owns the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const process_paging_fault_typeValue = enum {
    major,
    minor,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .major => "major",
            .minor => "minor",
        };
    }
};

/// The type of page fault for this data point. Type `major` is for major/hard page faults, and `minor` is for minor/soft page faults.
pub const process_paging_fault_type = types.EnumAttribute(process_paging_fault_typeValue){
    .name = "process.paging.fault_type",
    .brief = "The type of page fault for this data point. Type `major` is for major/hard page faults, and `minor` is for minor/soft page faults.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Parent Process identifier (PPID).
pub const process_parent_pid = types.IntAttribute{
    .name = "process.parent_pid",
    .brief = "Parent Process identifier (PPID).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Process identifier (PID).
pub const process_pid = types.IntAttribute{
    .name = "process.pid",
    .brief = "Process identifier (PID).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The real user ID (RUID) of the process.
pub const process_real_user_id = types.IntAttribute{
    .name = "process.real_user.id",
    .brief = "The real user ID (RUID) of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The username of the real user of the process.
pub const process_real_user_name = types.StringAttribute{
    .name = "process.real_user.name",
    .brief = "The username of the real user of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// An additional description about the runtime of the process, for example a specific vendor customization of the runtime environment.
pub const process_runtime_description = types.StringAttribute{
    .name = "process.runtime.description",
    .brief = "An additional description about the runtime of the process, for example a specific vendor customization of the runtime environment.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the runtime of this process.
pub const process_runtime_name = types.StringAttribute{
    .name = "process.runtime.name",
    .brief = "The name of the runtime of this process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version of the runtime of this process, as returned by the runtime without modification.
pub const process_runtime_version = types.StringAttribute{
    .name = "process.runtime.version",
    .brief = "The version of the runtime of this process, as returned by the runtime without modification.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The saved user ID (SUID) of the process.
pub const process_saved_user_id = types.IntAttribute{
    .name = "process.saved_user.id",
    .brief = "The saved user ID (SUID) of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The username of the saved user.
pub const process_saved_user_name = types.StringAttribute{
    .name = "process.saved_user.name",
    .brief = "The username of the saved user.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The PID of the process's session leader. This is also the session ID (SID) of the process.
pub const process_session_leader_pid = types.IntAttribute{
    .name = "process.session_leader.pid",
    .brief = "The PID of the process's session leader. This is also the session ID (SID) of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Process title (proctitle)
pub const process_title = types.StringAttribute{
    .name = "process.title",
    .brief = "Process title (proctitle)",
    .note = "In many Unix-like systems, process title (proctitle), is the string that represents the name or command line of a running process, displayed by system monitoring tools like ps, top, and htop.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The effective user ID (EUID) of the process.
pub const process_user_id = types.IntAttribute{
    .name = "process.user.id",
    .brief = "The effective user ID (EUID) of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The username of the effective user of the process.
pub const process_user_name = types.StringAttribute{
    .name = "process.user.name",
    .brief = "The username of the effective user of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Virtual process identifier.
pub const process_vpid = types.IntAttribute{
    .name = "process.vpid",
    .brief = "Virtual process identifier.",
    .note = "The process ID within a PID namespace. This is not necessarily unique across all processes on the host but it is unique within the process namespace that the process exists within.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The working directory of the process.
pub const process_working_directory = types.StringAttribute{
    .name = "process.working_directory",
    .brief = "The working directory of the process.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const profile_frame_typeValue = enum {
    dotnet,
    jvm,
    kernel,
    native,
    perl,
    php,
    cpython,
    ruby,
    v8js,
    beam,
    go,
    rust,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .dotnet => "dotnet",
            .jvm => "jvm",
            .kernel => "kernel",
            .native => "native",
            .perl => "perl",
            .php => "php",
            .cpython => "cpython",
            .ruby => "ruby",
            .v8js => "v8js",
            .beam => "beam",
            .go => "go",
            .rust => "rust",
        };
    }
};

/// Describes the interpreter or compiler of a single frame.
pub const profile_frame_type = types.EnumAttribute(profile_frame_typeValue){
    .name = "profile.frame.type",
    .brief = "Describes the interpreter or compiler of a single frame.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const rpc_connect_rpc_error_codeValue = enum {
    cancelled,
    unknown,
    invalid_argument,
    deadline_exceeded,
    not_found,
    already_exists,
    permission_denied,
    resource_exhausted,
    failed_precondition,
    aborted,
    out_of_range,
    unimplemented,
    internal,
    unavailable,
    data_loss,
    unauthenticated,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .cancelled => "cancelled",
            .unknown => "unknown",
            .invalid_argument => "invalid_argument",
            .deadline_exceeded => "deadline_exceeded",
            .not_found => "not_found",
            .already_exists => "already_exists",
            .permission_denied => "permission_denied",
            .resource_exhausted => "resource_exhausted",
            .failed_precondition => "failed_precondition",
            .aborted => "aborted",
            .out_of_range => "out_of_range",
            .unimplemented => "unimplemented",
            .internal => "internal",
            .unavailable => "unavailable",
            .data_loss => "data_loss",
            .unauthenticated => "unauthenticated",
        };
    }
};

/// The [error codes](https://connectrpc.com//docs/protocol/#error-codes) of the Connect request. Error codes are always string values.
pub const rpc_connect_rpc_error_code = types.EnumAttribute(rpc_connect_rpc_error_codeValue){
    .name = "rpc.connect_rpc.error_code",
    .brief = "The [error codes](https://connectrpc.com//docs/protocol/#error-codes) of the Connect request. Error codes are always string values.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Connect request metadata, ``key`` being the normalized Connect Metadata key (lowercase), the value being the metadata values.
pub const rpc_connect_rpc_request_metadata = types.StringArrayAttribute{
    .name = "rpc.connect_rpc.request.metadata",
    .brief = "Connect request metadata, ``key`` being the normalized Connect Metadata key (lowercase), the value being the metadata values.",
    .note = "Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all request metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.  For example, a property `my-custom-key` with value `[\"1.2.3.4\", \"1.2.3.5\"]` SHOULD be recorded as the `rpc.connect_rpc.request.metadata.my-custom-key` attribute with value `[\"1.2.3.4\", \"1.2.3.5\"]`",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Connect response metadata, ``key`` being the normalized Connect Metadata key (lowercase), the value being the metadata values.
pub const rpc_connect_rpc_response_metadata = types.StringArrayAttribute{
    .name = "rpc.connect_rpc.response.metadata",
    .brief = "Connect response metadata, ``key`` being the normalized Connect Metadata key (lowercase), the value being the metadata values.",
    .note = "Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all response metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.  For example, a property `my-custom-key` with value `\"attribute_value\"` SHOULD be recorded as the `rpc.connect_rpc.response.metadata.my-custom-key` attribute with value `[\"attribute_value\"]`",
    .stability = .development,
    .requirement_level = .recommended,
};
/// gRPC request metadata, ``key`` being the normalized gRPC Metadata key (lowercase), the value being the metadata values.
pub const rpc_grpc_request_metadata = types.StringArrayAttribute{
    .name = "rpc.grpc.request.metadata",
    .brief = "gRPC request metadata, ``key`` being the normalized gRPC Metadata key (lowercase), the value being the metadata values.",
    .note = "Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all request metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.  For example, a property `my-custom-key` with value `[\"1.2.3.4\", \"1.2.3.5\"]` SHOULD be recorded as `rpc.grpc.request.metadata.my-custom-key` attribute with value `[\"1.2.3.4\", \"1.2.3.5\"]`",
    .stability = .development,
    .requirement_level = .recommended,
};
/// gRPC response metadata, ``key`` being the normalized gRPC Metadata key (lowercase), the value being the metadata values.
pub const rpc_grpc_response_metadata = types.StringArrayAttribute{
    .name = "rpc.grpc.response.metadata",
    .brief = "gRPC response metadata, ``key`` being the normalized gRPC Metadata key (lowercase), the value being the metadata values.",
    .note = "Instrumentations SHOULD require an explicit configuration of which metadata values are to be captured. Including all response metadata values can be a security risk - explicit configuration helps avoid leaking sensitive information.  For example, a property `my-custom-key` with value `[\"attribute_value\"]` SHOULD be recorded as the `rpc.grpc.response.metadata.my-custom-key` attribute with value `[\"attribute_value\"]`",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const rpc_grpc_status_codeValue = enum {
    ok,
    cancelled,
    unknown,
    invalid_argument,
    deadline_exceeded,
    not_found,
    already_exists,
    permission_denied,
    resource_exhausted,
    failed_precondition,
    aborted,
    out_of_range,
    unimplemented,
    internal,
    unavailable,
    data_loss,
    unauthenticated,
    pub fn toInt(self: @This()) i64 {
        return switch (self) {
            .ok => 0,
            .cancelled => 1,
            .unknown => 2,
            .invalid_argument => 3,
            .deadline_exceeded => 4,
            .not_found => 5,
            .already_exists => 6,
            .permission_denied => 7,
            .resource_exhausted => 8,
            .failed_precondition => 9,
            .aborted => 10,
            .out_of_range => 11,
            .unimplemented => 12,
            .internal => 13,
            .unavailable => 14,
            .data_loss => 15,
            .unauthenticated => 16,
        };
    }
};

/// The [numeric status code](https://github.com/grpc/grpc/blob/v1.33.2/doc/statuscodes.md) of the gRPC request.
pub const rpc_grpc_status_code = types.IntEnumAttribute(rpc_grpc_status_codeValue){
    .name = "rpc.grpc.status_code",
    .brief = "The [numeric status code](https://github.com/grpc/grpc/blob/v1.33.2/doc/statuscodes.md) of the gRPC request.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// `error.code` property of response if it is an error response.
pub const rpc_jsonrpc_error_code = types.IntAttribute{
    .name = "rpc.jsonrpc.error_code",
    .brief = "`error.code` property of response if it is an error response.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// `error.message` property of response if it is an error response.
pub const rpc_jsonrpc_error_message = types.StringAttribute{
    .name = "rpc.jsonrpc.error_message",
    .brief = "`error.message` property of response if it is an error response.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// `id` property of request or response. Since protocol allows id to be int, string, `null` or missing (for notifications), value is expected to be cast to string for simplicity. Use empty string in case of `null` value. Omit entirely if this is a notification.
pub const rpc_jsonrpc_request_id = types.StringAttribute{
    .name = "rpc.jsonrpc.request_id",
    .brief = "`id` property of request or response. Since protocol allows id to be int, string, `null` or missing (for notifications), value is expected to be cast to string for simplicity. Use empty string in case of `null` value. Omit entirely if this is a notification.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Protocol version as in `jsonrpc` property of request/response. Since JSON-RPC 1.0 doesn't specify this, the value can be omitted.
pub const rpc_jsonrpc_version = types.StringAttribute{
    .name = "rpc.jsonrpc.version",
    .brief = "Protocol version as in `jsonrpc` property of request/response. Since JSON-RPC 1.0 doesn't specify this, the value can be omitted.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Compressed size of the message in bytes.
pub const rpc_message_compressed_size = types.IntAttribute{
    .name = "rpc.message.compressed_size",
    .brief = "Compressed size of the message in bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// MUST be calculated as two different counters starting from `1` one for sent messages and one for received message.
pub const rpc_message_id = types.IntAttribute{
    .name = "rpc.message.id",
    .brief = "MUST be calculated as two different counters starting from `1` one for sent messages and one for received message.",
    .note = "This way we guarantee that the values will be consistent between different implementations.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const rpc_message_typeValue = enum {
    sent,
    received,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .sent => "SENT",
            .received => "RECEIVED",
        };
    }
};

/// Whether this is a received or sent message.
pub const rpc_message_type = types.EnumAttribute(rpc_message_typeValue){
    .name = "rpc.message.type",
    .brief = "Whether this is a received or sent message.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Uncompressed size of the message in bytes.
pub const rpc_message_uncompressed_size = types.IntAttribute{
    .name = "rpc.message.uncompressed_size",
    .brief = "Uncompressed size of the message in bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the (logical) method being called, must be equal to the $method part in the span name.
pub const rpc_method = types.StringAttribute{
    .name = "rpc.method",
    .brief = "The name of the (logical) method being called, must be equal to the $method part in the span name.",
    .note = "This is the logical name of the method from the RPC interface perspective, which can be different from the name of any implementing method/function. The `code.function.name` attribute may be used to store the latter (e.g., method actually executing the call on the server side, RPC client stub method on the client side).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The full (logical) name of the service being called, including its package name, if applicable.
pub const rpc_service = types.StringAttribute{
    .name = "rpc.service",
    .brief = "The full (logical) name of the service being called, including its package name, if applicable.",
    .note = "This is the logical name of the service from the RPC interface perspective, which can be different from the name of any implementing class. The `code.namespace` attribute may be used to store the latter (despite the attribute name, it may include a class name; e.g., class with method actually executing the call on the server side, RPC client stub class on the client side).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const rpc_systemValue = enum {
    grpc,
    java_rmi,
    dotnet_wcf,
    apache_dubbo,
    connect_rpc,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .grpc => "grpc",
            .java_rmi => "java_rmi",
            .dotnet_wcf => "dotnet_wcf",
            .apache_dubbo => "apache_dubbo",
            .connect_rpc => "connect_rpc",
        };
    }
};

/// A string identifying the remoting system. See below for a list of well-known identifiers.
pub const rpc_system = types.EnumAttribute(rpc_systemValue){
    .name = "rpc.system",
    .brief = "A string identifying the remoting system. See below for a list of well-known identifiers.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A categorization value keyword used by the entity using the rule for detection of this event
pub const security_rule_category = types.StringAttribute{
    .name = "security_rule.category",
    .brief = "A categorization value keyword used by the entity using the rule for detection of this event",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The description of the rule generating the event.
pub const security_rule_description = types.StringAttribute{
    .name = "security_rule.description",
    .brief = "The description of the rule generating the event.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the license under which the rule used to generate this event is made available.
pub const security_rule_license = types.StringAttribute{
    .name = "security_rule.license",
    .brief = "Name of the license under which the rule used to generate this event is made available.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the rule or signature generating the event.
pub const security_rule_name = types.StringAttribute{
    .name = "security_rule.name",
    .brief = "The name of the rule or signature generating the event.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Reference URL to additional information about the rule used to generate this event.
pub const security_rule_reference = types.StringAttribute{
    .name = "security_rule.reference",
    .brief = "Reference URL to additional information about the rule used to generate this event.",
    .note = "The URL can point to the vendor’s documentation about the rule. If that’s not available, it can also be a link to a more general page describing this type of alert.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the ruleset, policy, group, or parent category in which the rule used to generate this event is a member.
pub const security_rule_ruleset_name = types.StringAttribute{
    .name = "security_rule.ruleset.name",
    .brief = "Name of the ruleset, policy, group, or parent category in which the rule used to generate this event is a member.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A rule ID that is unique within the scope of a set or group of agents, observers, or other entities using the rule for detection of this event.
pub const security_rule_uuid = types.StringAttribute{
    .name = "security_rule.uuid",
    .brief = "A rule ID that is unique within the scope of a set or group of agents, observers, or other entities using the rule for detection of this event.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version / revision of the rule being used for analysis.
pub const security_rule_version = types.StringAttribute{
    .name = "security_rule.version",
    .brief = "The version / revision of the rule being used for analysis.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Server domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.
pub const server_address = types.StringAttribute{
    .name = "server.address",
    .brief = "Server domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.",
    .note = "When observed from the client side, and when communicating through an intermediary, `server.address` SHOULD represent the server address behind any intermediaries, for example proxies, if it's available.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Server port number.
pub const server_port = types.IntAttribute{
    .name = "server.port",
    .brief = "Server port number.",
    .note = "When observed from the client side, and when communicating through an intermediary, `server.port` SHOULD represent the server port behind any intermediaries, for example proxies, if it's available.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The string ID of the service instance.
pub const service_instance_id = types.StringAttribute{
    .name = "service.instance.id",
    .brief = "The string ID of the service instance.",
    .note = "MUST be unique for each instance of the same `service.namespace,service.name` pair (in other words `service.namespace,service.name,service.instance.id` triplet MUST be globally unique). The ID helps to distinguish instances of the same service that exist at the same time (e.g. instances of a horizontally scaled service).  Implementations, such as SDKs, are recommended to generate a random Version 1 or Version 4 [RFC 4122](https://www.ietf.org/rfc/rfc4122.txt) UUID, but are free to use an inherent unique ID as the source of this value if stability is desirable. In that case, the ID SHOULD be used as source of a UUID Version 5 and SHOULD use the following UUID as the namespace: `4d63009a-8d0f-11ee-aad7-4c796ed8e320`.  UUIDs are typically recommended, as only an opaque value for the purposes of identifying a service instance is needed. Similar to what can be seen in the man page for the [`/etc/machine-id`](https://www.freedesktop.org/software/systemd/man/latest/machine-id.html) file, the underlying data, such as pod name and namespace should be treated as confidential, being the user's choice to expose it or not via another resource attribute.  For applications running behind an application server (like unicorn), we do not recommend using one identifier for all processes participating in the application. Instead, it's recommended each division (e.g. a worker thread in unicorn) to have its own instance.id.  It's not recommended for a Collector to set `service.instance.id` if it can't unambiguously determine the service instance that is generating that telemetry. For instance, creating an UUID based on `pod.name` will likely be wrong, as the Collector might not know from which container within that pod the telemetry originated. However, Collectors can set the `service.instance.id` if they can unambiguously determine the service instance for that telemetry. This is typically the case for scraping receivers, as they know the target address and port.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Logical name of the service.
pub const service_name = types.StringAttribute{
    .name = "service.name",
    .brief = "Logical name of the service.",
    .note = "MUST be the same for all instances of horizontally scaled services. If the value was not specified, SDKs MUST fallback to `unknown_service:` concatenated with [`process.executable.name`](process.md), e.g. `unknown_service:bash`. If `process.executable.name` is not available, the value MUST be set to `unknown_service`.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// A namespace for `service.name`.
pub const service_namespace = types.StringAttribute{
    .name = "service.namespace",
    .brief = "A namespace for `service.name`.",
    .note = "A string value having a meaning that helps to distinguish a group of services, for example the team name that owns a group of services. `service.name` is expected to be unique within the same namespace. If `service.namespace` is not specified in the Resource then `service.name` is expected to be unique for all services that have no explicit namespace defined (so the empty/unspecified namespace is simply one more valid namespace). Zero-length namespace string is assumed equal to unspecified namespace.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version string of the service API or implementation. The format is not defined by these conventions.
pub const service_version = types.StringAttribute{
    .name = "service.version",
    .brief = "The version string of the service API or implementation. The format is not defined by these conventions.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// A unique id to identify a session.
pub const session_id = types.StringAttribute{
    .name = "session.id",
    .brief = "A unique id to identify a session.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The previous `session.id` for this user, when known.
pub const session_previous_id = types.StringAttribute{
    .name = "session.previous_id",
    .brief = "The previous `session.id` for this user, when known.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const signalr_connection_statusValue = enum {
    normal_closure,
    timeout,
    app_shutdown,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .normal_closure => "normal_closure",
            .timeout => "timeout",
            .app_shutdown => "app_shutdown",
        };
    }
};

/// SignalR HTTP connection closure status.
pub const signalr_connection_status = types.EnumAttribute(signalr_connection_statusValue){
    .name = "signalr.connection.status",
    .brief = "SignalR HTTP connection closure status.",
    .stability = .stable,
    .requirement_level = .recommended,
};
pub const signalr_transportValue = enum {
    server_sent_events,
    long_polling,
    web_sockets,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .server_sent_events => "server_sent_events",
            .long_polling => "long_polling",
            .web_sockets => "web_sockets",
        };
    }
};

/// [SignalR transport type](https://github.com/dotnet/aspnetcore/blob/main/src/SignalR/docs/specs/TransportProtocols.md)
pub const signalr_transport = types.EnumAttribute(signalr_transportValue){
    .name = "signalr.transport",
    .brief = "[SignalR transport type](https://github.com/dotnet/aspnetcore/blob/main/src/SignalR/docs/specs/TransportProtocols.md)",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Source address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.
pub const source_address = types.StringAttribute{
    .name = "source.address",
    .brief = "Source address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.",
    .note = "When observed from the destination side, and when communicating through an intermediary, `source.address` SHOULD represent the source address behind any intermediaries, for example proxies, if it's available.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Source port number
pub const source_port = types.IntAttribute{
    .name = "source.port",
    .brief = "Source port number",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `cpu.logical_number` instead.
pub const system_cpu_logical_number = types.IntAttribute{
    .name = "system.cpu.logical_number",
    .brief = "Deprecated, use `cpu.logical_number` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_cpu_stateValue = enum {
    user,
    system,
    nice,
    idle,
    iowait,
    interrupt,
    steal,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .user => "user",
            .system => "system",
            .nice => "nice",
            .idle => "idle",
            .iowait => "iowait",
            .interrupt => "interrupt",
            .steal => "steal",
        };
    }
};

/// Deprecated, use `cpu.mode` instead.
pub const system_cpu_state = types.EnumAttribute(system_cpu_stateValue){
    .name = "system.cpu.state",
    .brief = "Deprecated, use `cpu.mode` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The device identifier
pub const system_device = types.StringAttribute{
    .name = "system.device",
    .brief = "The device identifier",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The filesystem mode
pub const system_filesystem_mode = types.StringAttribute{
    .name = "system.filesystem.mode",
    .brief = "The filesystem mode",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The filesystem mount path
pub const system_filesystem_mountpoint = types.StringAttribute{
    .name = "system.filesystem.mountpoint",
    .brief = "The filesystem mount path",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_filesystem_stateValue = enum {
    used,
    free,
    reserved,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .used => "used",
            .free => "free",
            .reserved => "reserved",
        };
    }
};

/// The filesystem state
pub const system_filesystem_state = types.EnumAttribute(system_filesystem_stateValue){
    .name = "system.filesystem.state",
    .brief = "The filesystem state",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_filesystem_typeValue = enum {
    fat32,
    exfat,
    ntfs,
    refs,
    hfsplus,
    ext4,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .fat32 => "fat32",
            .exfat => "exfat",
            .ntfs => "ntfs",
            .refs => "refs",
            .hfsplus => "hfsplus",
            .ext4 => "ext4",
        };
    }
};

/// The filesystem type
pub const system_filesystem_type = types.EnumAttribute(system_filesystem_typeValue){
    .name = "system.filesystem.type",
    .brief = "The filesystem type",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_memory_stateValue = enum {
    used,
    free,
    shared,
    buffers,
    cached,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .used => "used",
            .free => "free",
            .shared => "shared",
            .buffers => "buffers",
            .cached => "cached",
        };
    }
};

/// The memory state
pub const system_memory_state = types.EnumAttribute(system_memory_stateValue){
    .name = "system.memory.state",
    .brief = "The memory state",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_network_stateValue = enum {
    close,
    close_wait,
    closing,
    delete,
    established,
    fin_wait_1,
    fin_wait_2,
    last_ack,
    listen,
    syn_recv,
    syn_sent,
    time_wait,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .close => "close",
            .close_wait => "close_wait",
            .closing => "closing",
            .delete => "delete",
            .established => "established",
            .fin_wait_1 => "fin_wait_1",
            .fin_wait_2 => "fin_wait_2",
            .last_ack => "last_ack",
            .listen => "listen",
            .syn_recv => "syn_recv",
            .syn_sent => "syn_sent",
            .time_wait => "time_wait",
        };
    }
};

/// Deprecated, use `network.connection.state` instead.
pub const system_network_state = types.EnumAttribute(system_network_stateValue){
    .name = "system.network.state",
    .brief = "Deprecated, use `network.connection.state` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_paging_directionValue = enum {
    in,
    out,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .in => "in",
            .out => "out",
        };
    }
};

/// The paging access direction
pub const system_paging_direction = types.EnumAttribute(system_paging_directionValue){
    .name = "system.paging.direction",
    .brief = "The paging access direction",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_paging_stateValue = enum {
    used,
    free,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .used => "used",
            .free => "free",
        };
    }
};

/// The memory paging state
pub const system_paging_state = types.EnumAttribute(system_paging_stateValue){
    .name = "system.paging.state",
    .brief = "The memory paging state",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_paging_typeValue = enum {
    major,
    minor,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .major => "major",
            .minor => "minor",
        };
    }
};

/// The memory paging type
pub const system_paging_type = types.EnumAttribute(system_paging_typeValue){
    .name = "system.paging.type",
    .brief = "The memory paging type",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_process_statusValue = enum {
    running,
    sleeping,
    stopped,
    defunct,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .running => "running",
            .sleeping => "sleeping",
            .stopped => "stopped",
            .defunct => "defunct",
        };
    }
};

/// The process state, e.g., [Linux Process State Codes](https://man7.org/linux/man-pages/man1/ps.1.html#PROCESS_STATE_CODES)
pub const system_process_status = types.EnumAttribute(system_process_statusValue){
    .name = "system.process.status",
    .brief = "The process state, e.g., [Linux Process State Codes](https://man7.org/linux/man-pages/man1/ps.1.html#PROCESS_STATE_CODES)",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const system_processes_statusValue = enum {
    running,
    sleeping,
    stopped,
    defunct,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .running => "running",
            .sleeping => "sleeping",
            .stopped => "stopped",
            .defunct => "defunct",
        };
    }
};

/// Deprecated, use `system.process.status` instead.
pub const system_processes_status = types.EnumAttribute(system_processes_statusValue){
    .name = "system.processes.status",
    .brief = "Deprecated, use `system.process.status` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the auto instrumentation agent or distribution, if used.
pub const telemetry_distro_name = types.StringAttribute{
    .name = "telemetry.distro.name",
    .brief = "The name of the auto instrumentation agent or distribution, if used.",
    .note = "Official auto instrumentation agents and distributions SHOULD set the `telemetry.distro.name` attribute to a string starting with `opentelemetry-`, e.g. `opentelemetry-java-instrumentation`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version string of the auto instrumentation agent or distribution, if used.
pub const telemetry_distro_version = types.StringAttribute{
    .name = "telemetry.distro.version",
    .brief = "The version string of the auto instrumentation agent or distribution, if used.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const telemetry_sdk_languageValue = enum {
    cpp,
    dotnet,
    erlang,
    go,
    java,
    nodejs,
    php,
    python,
    ruby,
    rust,
    swift,
    webjs,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .cpp => "cpp",
            .dotnet => "dotnet",
            .erlang => "erlang",
            .go => "go",
            .java => "java",
            .nodejs => "nodejs",
            .php => "php",
            .python => "python",
            .ruby => "ruby",
            .rust => "rust",
            .swift => "swift",
            .webjs => "webjs",
        };
    }
};

/// The language of the telemetry SDK.
pub const telemetry_sdk_language = types.EnumAttribute(telemetry_sdk_languageValue){
    .name = "telemetry.sdk.language",
    .brief = "The language of the telemetry SDK.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The name of the telemetry SDK as defined above.
pub const telemetry_sdk_name = types.StringAttribute{
    .name = "telemetry.sdk.name",
    .brief = "The name of the telemetry SDK as defined above.",
    .note = "The OpenTelemetry SDK MUST set the `telemetry.sdk.name` attribute to `opentelemetry`. If another SDK, like a fork or a vendor-provided implementation, is used, this SDK MUST set the `telemetry.sdk.name` attribute to the fully-qualified class or module name of this SDK's main entry point or another suitable identifier depending on the language. The identifier `opentelemetry` is reserved and MUST NOT be used in this case. All custom identifiers SHOULD be stable across different versions of an implementation.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The version string of the telemetry SDK.
pub const telemetry_sdk_version = types.StringAttribute{
    .name = "telemetry.sdk.version",
    .brief = "The version string of the telemetry SDK.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The fully qualified human readable name of the [test case](https://wikipedia.org/wiki/Test_case).
pub const test_case_name = types.StringAttribute{
    .name = "test.case.name",
    .brief = "The fully qualified human readable name of the [test case](https://wikipedia.org/wiki/Test_case).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const test_case_result_statusValue = enum {
    pass,
    fail,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .pass => "pass",
            .fail => "fail",
        };
    }
};

/// The status of the actual test case result from test execution.
pub const test_case_result_status = types.EnumAttribute(test_case_result_statusValue){
    .name = "test.case.result.status",
    .brief = "The status of the actual test case result from test execution.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The human readable name of a [test suite](https://wikipedia.org/wiki/Test_suite).
pub const test_suite_name = types.StringAttribute{
    .name = "test.suite.name",
    .brief = "The human readable name of a [test suite](https://wikipedia.org/wiki/Test_suite).",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const test_suite_run_statusValue = enum {
    success,
    failure,
    skipped,
    aborted,
    timed_out,
    in_progress,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .success => "success",
            .failure => "failure",
            .skipped => "skipped",
            .aborted => "aborted",
            .timed_out => "timed_out",
            .in_progress => "in_progress",
        };
    }
};

/// The status of the test suite run.
pub const test_suite_run_status = types.EnumAttribute(test_suite_run_statusValue){
    .name = "test.suite.run.status",
    .brief = "The status of the test suite run.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Current "managed" thread ID (as opposed to OS thread ID).
pub const thread_id = types.IntAttribute{
    .name = "thread.id",
    .brief = "Current \"managed\" thread ID (as opposed to OS thread ID).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Current thread name.
pub const thread_name = types.StringAttribute{
    .name = "thread.name",
    .brief = "Current thread name.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// String indicating the [cipher](https://datatracker.ietf.org/doc/html/rfc5246#appendix-A.5) used during the current connection.
pub const tls_cipher = types.StringAttribute{
    .name = "tls.cipher",
    .brief = "String indicating the [cipher](https://datatracker.ietf.org/doc/html/rfc5246#appendix-A.5) used during the current connection.",
    .note = "The values allowed for `tls.cipher` MUST be one of the `Descriptions` of the [registered TLS Cipher Suits](https://www.iana.org/assignments/tls-parameters/tls-parameters.xhtml#table-tls-parameters-4).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// PEM-encoded stand-alone certificate offered by the client. This is usually mutually-exclusive of `client.certificate_chain` since this value also exists in that list.
pub const tls_client_certificate = types.StringAttribute{
    .name = "tls.client.certificate",
    .brief = "PEM-encoded stand-alone certificate offered by the client. This is usually mutually-exclusive of `client.certificate_chain` since this value also exists in that list.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Array of PEM-encoded certificates that make up the certificate chain offered by the client. This is usually mutually-exclusive of `client.certificate` since that value should be the first certificate in the chain.
pub const tls_client_certificate_chain = types.StringArrayAttribute{
    .name = "tls.client.certificate_chain",
    .brief = "Array of PEM-encoded certificates that make up the certificate chain offered by the client. This is usually mutually-exclusive of `client.certificate` since that value should be the first certificate in the chain.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Certificate fingerprint using the MD5 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.
pub const tls_client_hash_md5 = types.StringAttribute{
    .name = "tls.client.hash.md5",
    .brief = "Certificate fingerprint using the MD5 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Certificate fingerprint using the SHA1 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.
pub const tls_client_hash_sha1 = types.StringAttribute{
    .name = "tls.client.hash.sha1",
    .brief = "Certificate fingerprint using the SHA1 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Certificate fingerprint using the SHA256 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.
pub const tls_client_hash_sha256 = types.StringAttribute{
    .name = "tls.client.hash.sha256",
    .brief = "Certificate fingerprint using the SHA256 digest of DER-encoded version of certificate offered by the client. For consistency with other hash values, this value should be formatted as an uppercase hash.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Distinguished name of [subject](https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.6) of the issuer of the x.509 certificate presented by the client.
pub const tls_client_issuer = types.StringAttribute{
    .name = "tls.client.issuer",
    .brief = "Distinguished name of [subject](https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.6) of the issuer of the x.509 certificate presented by the client.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A hash that identifies clients based on how they perform an SSL/TLS handshake.
pub const tls_client_ja3 = types.StringAttribute{
    .name = "tls.client.ja3",
    .brief = "A hash that identifies clients based on how they perform an SSL/TLS handshake.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Date/Time indicating when client certificate is no longer considered valid.
pub const tls_client_not_after = types.StringAttribute{
    .name = "tls.client.not_after",
    .brief = "Date/Time indicating when client certificate is no longer considered valid.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Date/Time indicating when client certificate is first considered valid.
pub const tls_client_not_before = types.StringAttribute{
    .name = "tls.client.not_before",
    .brief = "Date/Time indicating when client certificate is first considered valid.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `server.address` instead.
pub const tls_client_server_name = types.StringAttribute{
    .name = "tls.client.server_name",
    .brief = "Deprecated, use `server.address` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Distinguished name of subject of the x.509 certificate presented by the client.
pub const tls_client_subject = types.StringAttribute{
    .name = "tls.client.subject",
    .brief = "Distinguished name of subject of the x.509 certificate presented by the client.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Array of ciphers offered by the client during the client hello.
pub const tls_client_supported_ciphers = types.StringArrayAttribute{
    .name = "tls.client.supported_ciphers",
    .brief = "Array of ciphers offered by the client during the client hello.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// String indicating the curve used for the given cipher, when applicable
pub const tls_curve = types.StringAttribute{
    .name = "tls.curve",
    .brief = "String indicating the curve used for the given cipher, when applicable",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Boolean flag indicating if the TLS negotiation was successful and transitioned to an encrypted tunnel.
pub const tls_established = types.BooleanAttribute{
    .name = "tls.established",
    .brief = "Boolean flag indicating if the TLS negotiation was successful and transitioned to an encrypted tunnel.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// String indicating the protocol being tunneled. Per the values in the [IANA registry](https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml#alpn-protocol-ids), this string should be lower case.
pub const tls_next_protocol = types.StringAttribute{
    .name = "tls.next_protocol",
    .brief = "String indicating the protocol being tunneled. Per the values in the [IANA registry](https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml#alpn-protocol-ids), this string should be lower case.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const tls_protocol_nameValue = enum {
    ssl,
    tls,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .ssl => "ssl",
            .tls => "tls",
        };
    }
};

/// Normalized lowercase protocol name parsed from original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)
pub const tls_protocol_name = types.EnumAttribute(tls_protocol_nameValue){
    .name = "tls.protocol.name",
    .brief = "Normalized lowercase protocol name parsed from original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Numeric part of the version parsed from the original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)
pub const tls_protocol_version = types.StringAttribute{
    .name = "tls.protocol.version",
    .brief = "Numeric part of the version parsed from the original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Boolean flag indicating if this TLS connection was resumed from an existing TLS negotiation.
pub const tls_resumed = types.BooleanAttribute{
    .name = "tls.resumed",
    .brief = "Boolean flag indicating if this TLS connection was resumed from an existing TLS negotiation.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// PEM-encoded stand-alone certificate offered by the server. This is usually mutually-exclusive of `server.certificate_chain` since this value also exists in that list.
pub const tls_server_certificate = types.StringAttribute{
    .name = "tls.server.certificate",
    .brief = "PEM-encoded stand-alone certificate offered by the server. This is usually mutually-exclusive of `server.certificate_chain` since this value also exists in that list.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Array of PEM-encoded certificates that make up the certificate chain offered by the server. This is usually mutually-exclusive of `server.certificate` since that value should be the first certificate in the chain.
pub const tls_server_certificate_chain = types.StringArrayAttribute{
    .name = "tls.server.certificate_chain",
    .brief = "Array of PEM-encoded certificates that make up the certificate chain offered by the server. This is usually mutually-exclusive of `server.certificate` since that value should be the first certificate in the chain.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Certificate fingerprint using the MD5 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.
pub const tls_server_hash_md5 = types.StringAttribute{
    .name = "tls.server.hash.md5",
    .brief = "Certificate fingerprint using the MD5 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Certificate fingerprint using the SHA1 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.
pub const tls_server_hash_sha1 = types.StringAttribute{
    .name = "tls.server.hash.sha1",
    .brief = "Certificate fingerprint using the SHA1 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Certificate fingerprint using the SHA256 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.
pub const tls_server_hash_sha256 = types.StringAttribute{
    .name = "tls.server.hash.sha256",
    .brief = "Certificate fingerprint using the SHA256 digest of DER-encoded version of certificate offered by the server. For consistency with other hash values, this value should be formatted as an uppercase hash.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Distinguished name of [subject](https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.6) of the issuer of the x.509 certificate presented by the client.
pub const tls_server_issuer = types.StringAttribute{
    .name = "tls.server.issuer",
    .brief = "Distinguished name of [subject](https://datatracker.ietf.org/doc/html/rfc5280#section-4.1.2.6) of the issuer of the x.509 certificate presented by the client.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// A hash that identifies servers based on how they perform an SSL/TLS handshake.
pub const tls_server_ja3s = types.StringAttribute{
    .name = "tls.server.ja3s",
    .brief = "A hash that identifies servers based on how they perform an SSL/TLS handshake.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Date/Time indicating when server certificate is no longer considered valid.
pub const tls_server_not_after = types.StringAttribute{
    .name = "tls.server.not_after",
    .brief = "Date/Time indicating when server certificate is no longer considered valid.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Date/Time indicating when server certificate is first considered valid.
pub const tls_server_not_before = types.StringAttribute{
    .name = "tls.server.not_before",
    .brief = "Date/Time indicating when server certificate is first considered valid.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Distinguished name of subject of the x.509 certificate presented by the server.
pub const tls_server_subject = types.StringAttribute{
    .name = "tls.server.subject",
    .brief = "Distinguished name of subject of the x.509 certificate presented by the server.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Domain extracted from the `url.full`, such as "opentelemetry.io".
pub const url_domain = types.StringAttribute{
    .name = "url.domain",
    .brief = "Domain extracted from the `url.full`, such as \"opentelemetry.io\".",
    .note = "In some cases a URL may refer to an IP and/or port directly, without a domain name. In this case, the IP address would go to the domain field. If the URL contains a [literal IPv6 address](https://www.rfc-editor.org/rfc/rfc2732#section-2) enclosed by `[` and `]`, the `[` and `]` characters should also be captured in the domain field.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The file extension extracted from the `url.full`, excluding the leading dot.
pub const url_extension = types.StringAttribute{
    .name = "url.extension",
    .brief = "The file extension extracted from the `url.full`, excluding the leading dot.",
    .note = "The file extension is only set if it exists, as not every url has a file extension. When the file name has multiple extensions `example.tar.gz`, only the last one should be captured `gz`, not `tar.gz`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [URI fragment](https://www.rfc-editor.org/rfc/rfc3986#section-3.5) component
pub const url_fragment = types.StringAttribute{
    .name = "url.fragment",
    .brief = "The [URI fragment](https://www.rfc-editor.org/rfc/rfc3986#section-3.5) component",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Absolute URL describing a network resource according to [RFC3986](https://www.rfc-editor.org/rfc/rfc3986)
pub const url_full = types.StringAttribute{
    .name = "url.full",
    .brief = "Absolute URL describing a network resource according to [RFC3986](https://www.rfc-editor.org/rfc/rfc3986)",
    .note = "For network calls, URL usually has `scheme://host[:port][path][?query][#fragment]` format, where the fragment is not transmitted over HTTP, but if it is known, it SHOULD be included nevertheless.  `url.full` MUST NOT contain credentials passed via URL in form of `https://username:password@www.example.com/`. In such case username and password SHOULD be redacted and attribute's value SHOULD be `https://REDACTED:REDACTED@www.example.com/`.  `url.full` SHOULD capture the absolute URL when it is available (or can be reconstructed).  Sensitive content provided in `url.full` SHOULD be scrubbed when instrumentations can identify it.  ![Development](https://img.shields.io/badge/-development-blue) Query string values for the following keys SHOULD be redacted by default and replaced by the value `REDACTED`:  * [`AWSAccessKeyId`](https://docs.aws.amazon.com/AmazonS3/latest/userguide/RESTAuthentication.html#RESTAuthenticationQueryStringAuth) * [`Signature`](https://docs.aws.amazon.com/AmazonS3/latest/userguide/RESTAuthentication.html#RESTAuthenticationQueryStringAuth) * [`sig`](https://learn.microsoft.com/azure/storage/common/storage-sas-overview#sas-token) * [`X-Goog-Signature`](https://cloud.google.com/storage/docs/access-control/signed-urls)  This list is subject to change over time.  When a query string value is redacted, the query string key SHOULD still be preserved, e.g. `https://www.example.com/path?color=blue&sig=REDACTED`.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Unmodified original URL as seen in the event source.
pub const url_original = types.StringAttribute{
    .name = "url.original",
    .brief = "Unmodified original URL as seen in the event source.",
    .note = "In network monitoring, the observed URL may be a full URL, whereas in access logs, the URL is often just represented as a path. This field is meant to represent the URL as it was observed, complete or not. `url.original` might contain credentials passed via URL in form of `https://username:password@www.example.com/`. In such case password and username SHOULD NOT be redacted and attribute's value SHOULD remain the same.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [URI path](https://www.rfc-editor.org/rfc/rfc3986#section-3.3) component
pub const url_path = types.StringAttribute{
    .name = "url.path",
    .brief = "The [URI path](https://www.rfc-editor.org/rfc/rfc3986#section-3.3) component",
    .note = "Sensitive content provided in `url.path` SHOULD be scrubbed when instrumentations can identify it.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Port extracted from the `url.full`
pub const url_port = types.IntAttribute{
    .name = "url.port",
    .brief = "Port extracted from the `url.full`",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [URI query](https://www.rfc-editor.org/rfc/rfc3986#section-3.4) component
pub const url_query = types.StringAttribute{
    .name = "url.query",
    .brief = "The [URI query](https://www.rfc-editor.org/rfc/rfc3986#section-3.4) component",
    .note = "Sensitive content provided in `url.query` SHOULD be scrubbed when instrumentations can identify it.  ![Development](https://img.shields.io/badge/-development-blue) Query string values for the following keys SHOULD be redacted by default and replaced by the value `REDACTED`:  * [`AWSAccessKeyId`](https://docs.aws.amazon.com/AmazonS3/latest/userguide/RESTAuthentication.html#RESTAuthenticationQueryStringAuth) * [`Signature`](https://docs.aws.amazon.com/AmazonS3/latest/userguide/RESTAuthentication.html#RESTAuthenticationQueryStringAuth) * [`sig`](https://learn.microsoft.com/azure/storage/common/storage-sas-overview#sas-token) * [`X-Goog-Signature`](https://cloud.google.com/storage/docs/access-control/signed-urls)  This list is subject to change over time.  When a query string value is redacted, the query string key SHOULD still be preserved, e.g. `q=OpenTelemetry&sig=REDACTED`.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The highest registered url domain, stripped of the subdomain.
pub const url_registered_domain = types.StringAttribute{
    .name = "url.registered_domain",
    .brief = "The highest registered url domain, stripped of the subdomain.",
    .note = "This value can be determined precisely with the [public suffix list](https://publicsuffix.org/). For example, the registered domain for `foo.example.com` is `example.com`. Trying to approximate this by simply taking the last two labels will not work well for TLDs such as `co.uk`.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [URI scheme](https://www.rfc-editor.org/rfc/rfc3986#section-3.1) component identifying the used protocol.
pub const url_scheme = types.StringAttribute{
    .name = "url.scheme",
    .brief = "The [URI scheme](https://www.rfc-editor.org/rfc/rfc3986#section-3.1) component identifying the used protocol.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// The subdomain portion of a fully qualified domain name includes all of the names except the host name under the registered_domain. In a partially qualified domain, or if the qualification level of the full name cannot be determined, subdomain contains all of the names below the registered domain.
pub const url_subdomain = types.StringAttribute{
    .name = "url.subdomain",
    .brief = "The subdomain portion of a fully qualified domain name includes all of the names except the host name under the registered_domain. In a partially qualified domain, or if the qualification level of the full name cannot be determined, subdomain contains all of the names below the registered domain.",
    .note = "The subdomain portion of `www.east.mydomain.co.uk` is `east`. If the domain has multiple levels of subdomain, such as `sub2.sub1.example.com`, the subdomain field should contain `sub2.sub1`, with no trailing period.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The low-cardinality template of an [absolute path reference](https://www.rfc-editor.org/rfc/rfc3986#section-4.2).
pub const url_template = types.StringAttribute{
    .name = "url.template",
    .brief = "The low-cardinality template of an [absolute path reference](https://www.rfc-editor.org/rfc/rfc3986#section-4.2).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. For example, the top level domain for example.com is `com`.
pub const url_top_level_domain = types.StringAttribute{
    .name = "url.top_level_domain",
    .brief = "The effective top level domain (eTLD), also known as the domain suffix, is the last part of the domain name. For example, the top level domain for example.com is `com`.",
    .note = "This value can be determined precisely with the [public suffix list](https://publicsuffix.org/).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// User email address.
pub const user_email = types.StringAttribute{
    .name = "user.email",
    .brief = "User email address.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// User's full name
pub const user_full_name = types.StringAttribute{
    .name = "user.full_name",
    .brief = "User's full name",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Unique user hash to correlate information for a user in anonymized form.
pub const user_hash = types.StringAttribute{
    .name = "user.hash",
    .brief = "Unique user hash to correlate information for a user in anonymized form.",
    .note = "Useful if `user.id` or `user.name` contain confidential information and cannot be used.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Unique identifier of the user.
pub const user_id = types.StringAttribute{
    .name = "user.id",
    .brief = "Unique identifier of the user.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Short name or login/username of the user.
pub const user_name = types.StringAttribute{
    .name = "user.name",
    .brief = "Short name or login/username of the user.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Array of user roles at the time of the event.
pub const user_roles = types.StringArrayAttribute{
    .name = "user.roles",
    .brief = "Array of user roles at the time of the event.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Name of the user-agent extracted from original. Usually refers to the browser's name.
pub const user_agent_name = types.StringAttribute{
    .name = "user_agent.name",
    .brief = "Name of the user-agent extracted from original. Usually refers to the browser's name.",
    .note = "[Example](https://www.whatsmyua.info) of extracting browser's name from original string. In the case of using a user-agent for non-browser products, such as microservices with multiple names/versions inside the `user_agent.original`, the most significant name SHOULD be selected. In such a scenario it should align with `user_agent.version`",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Value of the [HTTP User-Agent](https://www.rfc-editor.org/rfc/rfc9110.html#field.user-agent) header sent by the client.
pub const user_agent_original = types.StringAttribute{
    .name = "user_agent.original",
    .brief = "Value of the [HTTP User-Agent](https://www.rfc-editor.org/rfc/rfc9110.html#field.user-agent) header sent by the client.",
    .stability = .stable,
    .requirement_level = .recommended,
};
/// Human readable operating system name.
pub const user_agent_os_name = types.StringAttribute{
    .name = "user_agent.os.name",
    .brief = "Human readable operating system name.",
    .note = "For mapping user agent strings to OS names, libraries such as [ua-parser](https://github.com/ua-parser) can be utilized.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version string of the operating system as defined in [Version Attributes](/docs/resource/README.md#version-attributes).
pub const user_agent_os_version = types.StringAttribute{
    .name = "user_agent.os.version",
    .brief = "The version string of the operating system as defined in [Version Attributes](/docs/resource/README.md#version-attributes).",
    .note = "For mapping user agent strings to OS versions, libraries such as [ua-parser](https://github.com/ua-parser) can be utilized.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const user_agent_synthetic_typeValue = enum {
    bot,
    @"test",
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .bot => "bot",
            .@"test" => "test",
        };
    }
};

/// Specifies the category of synthetic traffic, such as tests or bots.
pub const user_agent_synthetic_type = types.EnumAttribute(user_agent_synthetic_typeValue){
    .name = "user_agent.synthetic.type",
    .brief = "Specifies the category of synthetic traffic, such as tests or bots.",
    .note = "This attribute MAY be derived from the contents of the `user_agent.original` attribute. Components that populate the attribute are responsible for determining what they consider to be synthetic bot or test traffic. This attribute can either be set for self-identification purposes, or on telemetry detected to be generated as a result of a synthetic request. This attribute is useful for distinguishing between genuine client traffic and synthetic traffic generated by bots or tests.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Version of the user-agent extracted from original. Usually refers to the browser's version
pub const user_agent_version = types.StringAttribute{
    .name = "user_agent.version",
    .brief = "Version of the user-agent extracted from original. Usually refers to the browser's version",
    .note = "[Example](https://www.whatsmyua.info) of extracting browser's version from original string. In the case of using a user-agent for non-browser products, such as microservices with multiple names/versions inside the `user_agent.original`, the most significant version SHOULD be selected. In such a scenario it should align with `user_agent.name`",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const v8js_gc_typeValue = enum {
    major,
    minor,
    incremental,
    weakcb,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .major => "major",
            .minor => "minor",
            .incremental => "incremental",
            .weakcb => "weakcb",
        };
    }
};

/// The type of garbage collection.
pub const v8js_gc_type = types.EnumAttribute(v8js_gc_typeValue){
    .name = "v8js.gc.type",
    .brief = "The type of garbage collection.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const v8js_heap_space_nameValue = enum {
    new_space,
    old_space,
    code_space,
    map_space,
    large_object_space,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .new_space => "new_space",
            .old_space => "old_space",
            .code_space => "code_space",
            .map_space => "map_space",
            .large_object_space => "large_object_space",
        };
    }
};

/// The name of the space type of heap memory.
pub const v8js_heap_space_name = types.EnumAttribute(v8js_heap_space_nameValue){
    .name = "v8js.heap.space.name",
    .brief = "The name of the space type of heap memory.",
    .note = "Value can be retrieved from value `space_name` of [`v8.getHeapSpaceStatistics()`](https://nodejs.org/api/v8.html#v8getheapspacestatistics)",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The ID of the change (pull request/merge request/changelist) if applicable. This is usually a unique (within repository) identifier generated by the VCS system.
pub const vcs_change_id = types.StringAttribute{
    .name = "vcs.change.id",
    .brief = "The ID of the change (pull request/merge request/changelist) if applicable. This is usually a unique (within repository) identifier generated by the VCS system.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_change_stateValue = enum {
    open,
    wip,
    closed,
    merged,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .open => "open",
            .wip => "wip",
            .closed => "closed",
            .merged => "merged",
        };
    }
};

/// The state of the change (pull request/merge request/changelist).
pub const vcs_change_state = types.EnumAttribute(vcs_change_stateValue){
    .name = "vcs.change.state",
    .brief = "The state of the change (pull request/merge request/changelist).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The human readable title of the change (pull request/merge request/changelist). This title is often a brief summary of the change and may get merged in to a ref as the commit summary.
pub const vcs_change_title = types.StringAttribute{
    .name = "vcs.change.title",
    .brief = "The human readable title of the change (pull request/merge request/changelist). This title is often a brief summary of the change and may get merged in to a ref as the commit summary.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_line_change_typeValue = enum {
    added,
    removed,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .added => "added",
            .removed => "removed",
        };
    }
};

/// The type of line change being measured on a branch or change.
pub const vcs_line_change_type = types.EnumAttribute(vcs_line_change_typeValue){
    .name = "vcs.line_change.type",
    .brief = "The type of line change being measured on a branch or change.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The group owner within the version control system.
pub const vcs_owner_name = types.StringAttribute{
    .name = "vcs.owner.name",
    .brief = "The group owner within the version control system.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_provider_nameValue = enum {
    github,
    gitlab,
    gittea,
    gitea,
    bitbucket,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .github => "github",
            .gitlab => "gitlab",
            .gittea => "gittea",
            .gitea => "gitea",
            .bitbucket => "bitbucket",
        };
    }
};

/// The name of the version control system provider.
pub const vcs_provider_name = types.EnumAttribute(vcs_provider_nameValue){
    .name = "vcs.provider.name",
    .brief = "The name of the version control system provider.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the [reference](https://git-scm.com/docs/gitglossary#def_ref) such as **branch** or **tag** in the repository.
pub const vcs_ref_base_name = types.StringAttribute{
    .name = "vcs.ref.base.name",
    .brief = "The name of the [reference](https://git-scm.com/docs/gitglossary#def_ref) such as **branch** or **tag** in the repository.",
    .note = "`base` refers to the starting point of a change. For example, `main` would be the base reference of type branch if you've created a new reference of type branch from it and created new commits.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The revision, literally [revised version](https://www.merriam-webster.com/dictionary/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.
pub const vcs_ref_base_revision = types.StringAttribute{
    .name = "vcs.ref.base.revision",
    .brief = "The revision, literally [revised version](https://www.merriam-webster.com/dictionary/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.",
    .note = "`base` refers to the starting point of a change. For example, `main` would be the base reference of type branch if you've created a new reference of type branch from it and created new commits. The revision can be a full [hash value (see glossary)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf), of the recorded change to a ref within a repository pointing to a commit [commit](https://git-scm.com/docs/git-commit) object. It does not necessarily have to be a hash; it can simply define a [revision number](https://svnbook.red-bean.com/en/1.7/svn.tour.revs.specifiers.html) which is an integer that is monotonically increasing. In cases where it is identical to the `ref.base.name`, it SHOULD still be included. It is up to the implementer to decide which value to set as the revision based on the VCS system and situational context.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_ref_base_typeValue = enum {
    branch,
    tag,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .branch => "branch",
            .tag => "tag",
        };
    }
};

/// The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.
pub const vcs_ref_base_type = types.EnumAttribute(vcs_ref_base_typeValue){
    .name = "vcs.ref.base.type",
    .brief = "The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.",
    .note = "`base` refers to the starting point of a change. For example, `main` would be the base reference of type branch if you've created a new reference of type branch from it and created new commits.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the [reference](https://git-scm.com/docs/gitglossary#def_ref) such as **branch** or **tag** in the repository.
pub const vcs_ref_head_name = types.StringAttribute{
    .name = "vcs.ref.head.name",
    .brief = "The name of the [reference](https://git-scm.com/docs/gitglossary#def_ref) such as **branch** or **tag** in the repository.",
    .note = "`head` refers to where you are right now; the current reference at a given time.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The revision, literally [revised version](https://www.merriam-webster.com/dictionary/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.
pub const vcs_ref_head_revision = types.StringAttribute{
    .name = "vcs.ref.head.revision",
    .brief = "The revision, literally [revised version](https://www.merriam-webster.com/dictionary/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.",
    .note = "`head` refers to where you are right now; the current reference at a given time.The revision can be a full [hash value (see glossary)](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5.pdf), of the recorded change to a ref within a repository pointing to a commit [commit](https://git-scm.com/docs/git-commit) object. It does not necessarily have to be a hash; it can simply define a [revision number](https://svnbook.red-bean.com/en/1.7/svn.tour.revs.specifiers.html) which is an integer that is monotonically increasing. In cases where it is identical to the `ref.head.name`, it SHOULD still be included. It is up to the implementer to decide which value to set as the revision based on the VCS system and situational context.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_ref_head_typeValue = enum {
    branch,
    tag,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .branch => "branch",
            .tag => "tag",
        };
    }
};

/// The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.
pub const vcs_ref_head_type = types.EnumAttribute(vcs_ref_head_typeValue){
    .name = "vcs.ref.head.type",
    .brief = "The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.",
    .note = "`head` refers to where you are right now; the current reference at a given time.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_ref_typeValue = enum {
    branch,
    tag,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .branch => "branch",
            .tag => "tag",
        };
    }
};

/// The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.
pub const vcs_ref_type = types.EnumAttribute(vcs_ref_typeValue){
    .name = "vcs.ref.type",
    .brief = "The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `vcs.change.id` instead.
pub const vcs_repository_change_id = types.StringAttribute{
    .name = "vcs.repository.change.id",
    .brief = "Deprecated, use `vcs.change.id` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `vcs.change.title` instead.
pub const vcs_repository_change_title = types.StringAttribute{
    .name = "vcs.repository.change.title",
    .brief = "Deprecated, use `vcs.change.title` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The human readable name of the repository. It SHOULD NOT include any additional identifier like Group/SubGroup in GitLab or organization in GitHub.
pub const vcs_repository_name = types.StringAttribute{
    .name = "vcs.repository.name",
    .brief = "The human readable name of the repository. It SHOULD NOT include any additional identifier like Group/SubGroup in GitLab or organization in GitHub.",
    .note = "Due to it only being the name, it can clash with forks of the same repository if collecting telemetry across multiple orgs or groups in the same backends.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `vcs.ref.head.name` instead.
pub const vcs_repository_ref_name = types.StringAttribute{
    .name = "vcs.repository.ref.name",
    .brief = "Deprecated, use `vcs.ref.head.name` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Deprecated, use `vcs.ref.head.revision` instead.
pub const vcs_repository_ref_revision = types.StringAttribute{
    .name = "vcs.repository.ref.revision",
    .brief = "Deprecated, use `vcs.ref.head.revision` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_repository_ref_typeValue = enum {
    branch,
    tag,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .branch => "branch",
            .tag => "tag",
        };
    }
};

/// Deprecated, use `vcs.ref.head.type` instead.
pub const vcs_repository_ref_type = types.EnumAttribute(vcs_repository_ref_typeValue){
    .name = "vcs.repository.ref.type",
    .brief = "Deprecated, use `vcs.ref.head.type` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The [canonical URL](https://support.google.com/webmasters/answer/10347851?hl=en#:~:text=A%20canonical%20URL%20is%20the,Google%20chooses%20one%20as%20canonical.) of the repository providing the complete HTTP(S) address in order to locate and identify the repository through a browser.
pub const vcs_repository_url_full = types.StringAttribute{
    .name = "vcs.repository.url.full",
    .brief = "The [canonical URL](https://support.google.com/webmasters/answer/10347851?hl=en#:~:text=A%20canonical%20URL%20is%20the,Google%20chooses%20one%20as%20canonical.) of the repository providing the complete HTTP(S) address in order to locate and identify the repository through a browser.",
    .note = "In Git Version Control Systems, the canonical URL SHOULD NOT include the `.git` extension.",
    .stability = .development,
    .requirement_level = .recommended,
};
pub const vcs_revision_delta_directionValue = enum {
    behind,
    ahead,
    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .behind => "behind",
            .ahead => "ahead",
        };
    }
};

/// The type of revision comparison.
pub const vcs_revision_delta_direction = types.EnumAttribute(vcs_revision_delta_directionValue){
    .name = "vcs.revision_delta.direction",
    .brief = "The type of revision comparison.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// Additional description of the web engine (e.g. detailed version and edition information).
pub const webengine_description = types.StringAttribute{
    .name = "webengine.description",
    .brief = "Additional description of the web engine (e.g. detailed version and edition information).",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the web engine.
pub const webengine_name = types.StringAttribute{
    .name = "webengine.name",
    .brief = "The name of the web engine.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The version of the web engine.
pub const webengine_version = types.StringAttribute{
    .name = "webengine.version",
    .brief = "The version of the web engine.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The System Management Facility (SMF) Identifier uniquely identified a z/OS system within a SYSPLEX or mainframe environment and is used for system and performance analysis.
pub const zos_smf_id = types.StringAttribute{
    .name = "zos.smf.id",
    .brief = "The System Management Facility (SMF) Identifier uniquely identified a z/OS system within a SYSPLEX or mainframe environment and is used for system and performance analysis.",
    .stability = .development,
    .requirement_level = .recommended,
};
/// The name of the SYSPLEX to which the z/OS system belongs too.
pub const zos_sysplex_name = types.StringAttribute{
    .name = "zos.sysplex.name",
    .brief = "The name of the SYSPLEX to which the z/OS system belongs too.",
    .stability = .development,
    .requirement_level = .recommended,
};
test "semantic attributes" {
    std.testing.refAllDecls(@This());
}
