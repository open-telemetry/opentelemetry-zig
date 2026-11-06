// DO NOT EDIT, this is an auto-generated file
//
// If you want to update the file:
// - Edit the template at scripts/templates/registry/zig/trace.zig.j2
// - Run the script at scripts/generate-consts-from-spec.sh

//! # Semantic Trace Attributes
//!
//! The entire set of semantic trace attributes (or [conventions](https://opentelemetry.io/docs/concepts/semantic-conventions/)) defined by the project.

const std = @import("std");
const types = @import("types.zig");

/// This attribute represents the state of the application.
///
/// # Examples
///
/// - created
/// Note: This attribute is experimental and may change in the future.
pub const android_app_state = types.StringAttribute{
    .name = "android.app.state",
    .brief = "This attribute represents the state of the application.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The x (horizontal) coordinate of a screen coordinate, in screen pixels.
///
/// # Examples
///
/// - 0
/// - 131
/// Note: This attribute is experimental and may change in the future.
pub const app_screen_coordinate_x = types.IntAttribute{
    .name = "app.screen.coordinate.x",
    .brief = "The x (horizontal) coordinate of a screen coordinate, in screen pixels.",
    .stability = .development,
    .requirement_level = .required,
};

/// The y (vertical) component of a screen coordinate, in screen pixels.
///
/// # Examples
///
/// - 12
/// - 99
/// Note: This attribute is experimental and may change in the future.
pub const app_screen_coordinate_y = types.IntAttribute{
    .name = "app.screen.coordinate.y",
    .brief = "The y (vertical) component of a screen coordinate, in screen pixels.",
    .stability = .development,
    .requirement_level = .required,
};

/// An identifier that uniquely differentiates this widget from other widgets in the same application.
///
/// # Examples
///
/// - f9bc787d-ff05-48ad-90e1-fca1d46130b3
/// - submit_order_1829
/// Note: This attribute is experimental and may change in the future.
pub const app_widget_id = types.StringAttribute{
    .name = "app.widget.id",
    .brief = "An identifier that uniquely differentiates this widget from other widgets in the same application.",
    .stability = .development,
    .requirement_level = .required,
};

/// The name of an application widget.
///
/// # Examples
///
/// - submit
/// - attack
/// - Clear Cart
/// Note: This attribute is experimental and may change in the future.
pub const app_widget_name = types.StringAttribute{
    .name = "app.widget.name",
    .brief = "The name of an application widget.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The unique identifier of the AWS Bedrock Guardrail. A [guardrail](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html) helps safeguard and prevent unwanted behavior from model responses or user messages.
///
/// # Examples
///
/// - sgi5gkybzqak
/// Note: This attribute is experimental and may change in the future.
pub const aws_bedrock_guardrail_id = types.StringAttribute{
    .name = "aws.bedrock.guardrail.id",
    .brief = "The unique identifier of the AWS Bedrock Guardrail. A [guardrail](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html) helps safeguard and prevent unwanted behavior from model responses or user messages.",
    .stability = .development,
    .requirement_level = .required,
};

/// The unique identifier of the AWS Bedrock Knowledge base. A [knowledge base](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html) is a bank of information that can be queried by models to generate more relevant responses and augment prompts.
///
/// # Examples
///
/// - XFWUPB9PAW
/// Note: This attribute is experimental and may change in the future.
pub const aws_bedrock_knowledge_base_id = types.StringAttribute{
    .name = "aws.bedrock.knowledge_base.id",
    .brief = "The unique identifier of the AWS Bedrock Knowledge base. A [knowledge base](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html) is a bank of information that can be queried by models to generate more relevant responses and augment prompts.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The JSON-serialized value of each item in the `AttributeDefinitions` request field.
///
/// # Examples
///
/// - [\"{ \\"AttributeName\\": \\"string\\", \\"AttributeType\\": \\"string\\" }\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_attribute_definitions = types.StringArrayAttribute{
    .name = "aws.dynamodb.attribute_definitions",
    .brief = "The JSON-serialized value of each item in the `AttributeDefinitions` request field.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `AttributesToGet` request parameter.
///
/// # Examples
///
/// - [\"lives\", \"id\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_attributes_to_get = types.StringArrayAttribute{
    .name = "aws.dynamodb.attributes_to_get",
    .brief = "The value of the `AttributesToGet` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `ConsistentRead` request parameter.
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_consistent_read = types.BooleanAttribute{
    .name = "aws.dynamodb.consistent_read",
    .brief = "The value of the `ConsistentRead` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The JSON-serialized value of each item in the `ConsumedCapacity` response field.
///
/// # Examples
///
/// - [\"{ \\"CapacityUnits\\": number, \\"GlobalSecondaryIndexes\\": { \\"string\\" : { \\"CapacityUnits\\": number, \\"ReadCapacityUnits\\": number, \\"WriteCapacityUnits\\": number } }, \\"LocalSecondaryIndexes\\": { \\"string\\" : { \\"CapacityUnits\\": number, \\"ReadCapacityUnits\\": number, \\"WriteCapacityUnits\\": number } }, \\"ReadCapacityUnits\\": number, \\"Table\\": { \\"CapacityUnits\\": number, \\"ReadCapacityUnits\\": number, \\"WriteCapacityUnits\\": number }, \\"TableName\\": \\"string\\", \\"WriteCapacityUnits\\": number }\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_consumed_capacity = types.StringArrayAttribute{
    .name = "aws.dynamodb.consumed_capacity",
    .brief = "The JSON-serialized value of each item in the `ConsumedCapacity` response field.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `Count` response parameter.
///
/// # Examples
///
/// - 10
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_count = types.IntAttribute{
    .name = "aws.dynamodb.count",
    .brief = "The value of the `Count` response parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `ExclusiveStartTableName` request parameter.
///
/// # Examples
///
/// - Users
/// - CatsTable
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_exclusive_start_table = types.StringAttribute{
    .name = "aws.dynamodb.exclusive_start_table",
    .brief = "The value of the `ExclusiveStartTableName` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The JSON-serialized value of each item in the `GlobalSecondaryIndexUpdates` request field.
///
/// # Examples
///
/// - [\"{ \\"Create\\": { \\"IndexName\\": \\"string\\", \\"KeySchema\\": [ { \\"AttributeName\\": \\"string\\", \\"KeyType\\": \\"string\\" } ], \\"Projection\\": { \\"NonKeyAttributes\\": [ \\"string\\" ], \\"ProjectionType\\": \\"string\\" }, \\"ProvisionedThroughput\\": { \\"ReadCapacityUnits\\": number, \\"WriteCapacityUnits\\": number } }\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_global_secondary_index_updates = types.StringArrayAttribute{
    .name = "aws.dynamodb.global_secondary_index_updates",
    .brief = "The JSON-serialized value of each item in the `GlobalSecondaryIndexUpdates` request field.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The JSON-serialized value of each item of the `GlobalSecondaryIndexes` request field
///
/// # Examples
///
/// - [\"{ \\"IndexName\\": \\"string\\", \\"KeySchema\\": [ { \\"AttributeName\\": \\"string\\", \\"KeyType\\": \\"string\\" } ], \\"Projection\\": { \\"NonKeyAttributes\\": [ \\"string\\" ], \\"ProjectionType\\": \\"string\\" }, \\"ProvisionedThroughput\\": { \\"ReadCapacityUnits\\": number, \\"WriteCapacityUnits\\": number } }\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_global_secondary_indexes = types.StringArrayAttribute{
    .name = "aws.dynamodb.global_secondary_indexes",
    .brief = "The JSON-serialized value of each item of the `GlobalSecondaryIndexes` request field",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `IndexName` request parameter.
///
/// # Examples
///
/// - name_to_group
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_index_name = types.StringAttribute{
    .name = "aws.dynamodb.index_name",
    .brief = "The value of the `IndexName` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The JSON-serialized value of the `ItemCollectionMetrics` response field.
///
/// # Examples
///
/// - { \"string\" : [ { \"ItemCollectionKey\": { \"string\" : { \"B\": blob, \"BOOL\": boolean, \"BS\": [ blob ], \"L\": [ \"AttributeValue\" ], \"M\": { \"string\" : \"AttributeValue\" }, \"N\": \"string\", \"NS\": [ \"string\" ], \"NULL\": boolean, \"S\": \"string\", \"SS\": [ \"string\" ] } }, \"SizeEstimateRangeGB\": [ number ] } ] }
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_item_collection_metrics = types.StringAttribute{
    .name = "aws.dynamodb.item_collection_metrics",
    .brief = "The JSON-serialized value of the `ItemCollectionMetrics` response field.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `Limit` request parameter.
///
/// # Examples
///
/// - 10
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_limit = types.IntAttribute{
    .name = "aws.dynamodb.limit",
    .brief = "The value of the `Limit` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The JSON-serialized value of each item of the `LocalSecondaryIndexes` request field.
///
/// # Examples
///
/// - [\"{ \\"IndexArn\\": \\"string\\", \\"IndexName\\": \\"string\\", \\"IndexSizeBytes\\": number, \\"ItemCount\\": number, \\"KeySchema\\": [ { \\"AttributeName\\": \\"string\\", \\"KeyType\\": \\"string\\" } ], \\"Projection\\": { \\"NonKeyAttributes\\": [ \\"string\\" ], \\"ProjectionType\\": \\"string\\" } }\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_local_secondary_indexes = types.StringArrayAttribute{
    .name = "aws.dynamodb.local_secondary_indexes",
    .brief = "The JSON-serialized value of each item of the `LocalSecondaryIndexes` request field.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `ProjectionExpression` request parameter.
///
/// # Examples
///
/// - Title
/// - Title, Price, Color
/// - Title, Description, RelatedItems, ProductReviews
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_projection = types.StringAttribute{
    .name = "aws.dynamodb.projection",
    .brief = "The value of the `ProjectionExpression` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `ProvisionedThroughput.ReadCapacityUnits` request parameter.
///
/// # Examples
///
/// - 1.0
/// - 2.0
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_provisioned_read_capacity = types.DoubleAttribute{
    .name = "aws.dynamodb.provisioned_read_capacity",
    .brief = "The value of the `ProvisionedThroughput.ReadCapacityUnits` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `ProvisionedThroughput.WriteCapacityUnits` request parameter.
///
/// # Examples
///
/// - 1.0
/// - 2.0
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_provisioned_write_capacity = types.DoubleAttribute{
    .name = "aws.dynamodb.provisioned_write_capacity",
    .brief = "The value of the `ProvisionedThroughput.WriteCapacityUnits` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `ScanIndexForward` request parameter.
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_scan_forward = types.BooleanAttribute{
    .name = "aws.dynamodb.scan_forward",
    .brief = "The value of the `ScanIndexForward` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `ScannedCount` response parameter.
///
/// # Examples
///
/// - 50
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_scanned_count = types.IntAttribute{
    .name = "aws.dynamodb.scanned_count",
    .brief = "The value of the `ScannedCount` response parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `Segment` request parameter.
///
/// # Examples
///
/// - 10
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_segment = types.IntAttribute{
    .name = "aws.dynamodb.segment",
    .brief = "The value of the `Segment` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `Select` request parameter.
///
/// # Examples
///
/// - ALL_ATTRIBUTES
/// - COUNT
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_select = types.StringAttribute{
    .name = "aws.dynamodb.select",
    .brief = "The value of the `Select` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The number of items in the `TableNames` response parameter.
///
/// # Examples
///
/// - 20
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_table_count = types.IntAttribute{
    .name = "aws.dynamodb.table_count",
    .brief = "The number of items in the `TableNames` response parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The keys in the `RequestItems` object field.
///
/// # Examples
///
/// - [\"Users\", \"Cats\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_table_names = types.StringArrayAttribute{
    .name = "aws.dynamodb.table_names",
    .brief = "The keys in the `RequestItems` object field.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value of the `TotalSegments` request parameter.
///
/// # Examples
///
/// - 100
/// Note: This attribute is experimental and may change in the future.
pub const aws_dynamodb_total_segments = types.IntAttribute{
    .name = "aws.dynamodb.total_segments",
    .brief = "The value of the `TotalSegments` request parameter.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The AWS extended request ID as returned in the response header `x-amz-id-2`.
///
/// # Examples
///
/// - wzHcyEWfmOGDIE5QOhTAqFDoDWP3y8IUvpNINCwL9N4TEHbUw0/gZJ+VZTmCNCWR7fezEN3eCiQ=
/// Note: This attribute is experimental and may change in the future.
pub const aws_extended_request_id = types.StringAttribute{
    .name = "aws.extended_request_id",
    .brief = "The AWS extended request ID as returned in the response header `x-amz-id-2`.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The full invoked ARN as provided on the `Context` passed to the function (`Lambda-Runtime-Invoked-Function-Arn` header on the `/runtime/invocation/next` applicable).
///
/// # Examples
///
/// - arn:aws:lambda:us-east-1:123456:function:myfunction:myalias
/// Note: This attribute is experimental and may change in the future.
pub const aws_lambda_invoked_arn = types.StringAttribute{
    .name = "aws.lambda.invoked_arn",
    .brief = "The full invoked ARN as provided on the `Context` passed to the function (`Lambda-Runtime-Invoked-Function-Arn` header on the `/runtime/invocation/next` applicable).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UUID of the [AWS Lambda EvenSource Mapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html). An event source is mapped to a lambda function. It's contents are read by Lambda and used to trigger a function. This isn't available in the lambda execution context or the lambda runtime environtment. This is going to be populated by the AWS SDK for each language when that UUID is present. Some of these operations are Create/Delete/Get/List/Update EventSourceMapping.
///
/// # Examples
///
/// - 587ad24b-03b9-4413-8202-bbd56b36e5b7
/// Note: This attribute is experimental and may change in the future.
pub const aws_lambda_resource_mapping_id = types.StringAttribute{
    .name = "aws.lambda.resource_mapping.id",
    .brief = "The UUID of the [AWS Lambda EvenSource Mapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html). An event source is mapped to a lambda function. It's contents are read by Lambda and used to trigger a function. This isn't available in the lambda execution context or the lambda runtime environtment. This is going to be populated by the AWS SDK for each language when that UUID is present. Some of these operations are Create/Delete/Get/List/Update EventSourceMapping.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The AWS request ID as returned in the response headers `x-amzn-requestid`, `x-amzn-request-id` or `x-amz-request-id`.
///
/// # Examples
///
/// - 79b9da39-b7ae-508a-a6bc-864b2829c622
/// - C9ER4AJX75574TDJ
/// Note: This attribute is experimental and may change in the future.
pub const aws_request_id = types.StringAttribute{
    .name = "aws.request_id",
    .brief = "The AWS request ID as returned in the response headers `x-amzn-requestid`, `x-amzn-request-id` or `x-amz-request-id`.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The S3 bucket name the request refers to. Corresponds to the `--bucket` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.
///
/// # Examples
///
/// - some-bucket-name
/// Note: This attribute is experimental and may change in the future.
pub const aws_s3_bucket = types.StringAttribute{
    .name = "aws.s3.bucket",
    .brief = "The S3 bucket name the request refers to. Corresponds to the `--bucket` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The source object (in the form `bucket`/`key`) for the copy operation.
///
/// # Examples
///
/// - someFile.yml
/// Note: This attribute is experimental and may change in the future.
pub const aws_s3_copy_source = types.StringAttribute{
    .name = "aws.s3.copy_source",
    .brief = "The source object (in the form `bucket`/`key`) for the copy operation.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The delete request container that specifies the objects to be deleted.
///
/// # Examples
///
/// - Objects=[{Key=string,VersionId=string},{Key=string,VersionId=string}],Quiet=boolean
/// Note: This attribute is experimental and may change in the future.
pub const aws_s3_delete = types.StringAttribute{
    .name = "aws.s3.delete",
    .brief = "The delete request container that specifies the objects to be deleted.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The S3 object key the request refers to. Corresponds to the `--key` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.
///
/// # Examples
///
/// - someFile.yml
/// Note: This attribute is experimental and may change in the future.
pub const aws_s3_key = types.StringAttribute{
    .name = "aws.s3.key",
    .brief = "The S3 object key the request refers to. Corresponds to the `--key` parameter of the [S3 API](https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html) operations.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The part number of the part being uploaded in a multipart-upload operation. This is a positive integer between 1 and 10,000.
///
/// # Examples
///
/// - 3456
/// Note: This attribute is experimental and may change in the future.
pub const aws_s3_part_number = types.IntAttribute{
    .name = "aws.s3.part_number",
    .brief = "The part number of the part being uploaded in a multipart-upload operation. This is a positive integer between 1 and 10,000.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Upload ID that identifies the multipart upload.
///
/// # Examples
///
/// - dfRtDYWFbkRONycy.Yxwh66Yjlx.cph0gtNBtJ
/// Note: This attribute is experimental and may change in the future.
pub const aws_s3_upload_id = types.StringAttribute{
    .name = "aws.s3.upload_id",
    .brief = "Upload ID that identifies the multipart upload.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Deprecated, use `azure.service.request.id` instead.
///
/// # Examples
///
/// - 00000000-0000-0000-0000-000000000000
/// Note: This attribute is experimental and may change in the future.
/// Note: This attribute is deprecated. {"note": "Replaced by `azure.service.request.id`.", "reason": "renamed", "renamed_to": "azure.service.request.id"}
pub const az_service_request_id = types.StringAttribute{
    .name = "az.service_request_id",
    .brief = "Deprecated, use `azure.service.request.id` instead.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The unique identifier of the client instance.
///
/// # Examples
///
/// - 3ba4827d-4422-483f-b59f-85b74211c11d
/// - storage-client-1
/// Note: This attribute is experimental and may change in the future.
pub const azure_client_id = types.StringAttribute{
    .name = "azure.client.id",
    .brief = "The unique identifier of the client instance.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Cosmos client connection mode.
/// Note: This attribute is experimental and may change in the future.
pub const azure_cosmosdb_connection_mode = types.StringAttribute{
    .name = "azure.cosmosdb.connection.mode",
    .brief = "Cosmos client connection mode.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Account or request [consistency level](https://learn.microsoft.com/azure/cosmos-db/consistency-levels).
///
/// # Examples
///
/// - Eventual
/// - ConsistentPrefix
/// - BoundedStaleness
/// - Strong
/// - Session
/// Note: This attribute is experimental and may change in the future.
pub const azure_cosmosdb_consistency_level = types.StringAttribute{
    .name = "azure.cosmosdb.consistency.level",
    .brief = "Account or request [consistency level](https://learn.microsoft.com/azure/cosmos-db/consistency-levels).",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// List of regions contacted during operation in the order that they were contacted. If there is more than one region listed, it indicates that the operation was performed on multiple regions i.e. cross-regional call.
///
/// # Examples
///
/// - [\"North Central US\", \"Australia East\", \"Australia Southeast\"]
/// Note: This attribute is experimental and may change in the future.
pub const azure_cosmosdb_operation_contacted_regions = types.StringArrayAttribute{
    .name = "azure.cosmosdb.operation.contacted_regions",
    .brief = "List of regions contacted during operation in the order that they were contacted. If there is more than one region listed, it indicates that the operation was performed on multiple regions i.e. cross-regional call.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The number of request units consumed by the operation.
///
/// # Examples
///
/// - 46.18
/// - 1.0
/// Note: This attribute is experimental and may change in the future.
pub const azure_cosmosdb_operation_request_charge = types.DoubleAttribute{
    .name = "azure.cosmosdb.operation.request_charge",
    .brief = "The number of request units consumed by the operation.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Request payload size in bytes.
/// Note: This attribute is experimental and may change in the future.
pub const azure_cosmosdb_request_body_size = types.IntAttribute{
    .name = "azure.cosmosdb.request.body.size",
    .brief = "Request payload size in bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Cosmos DB sub status code.
///
/// # Examples
///
/// - 1000
/// - 1002
/// Note: This attribute is experimental and may change in the future.
pub const azure_cosmosdb_response_sub_status_code = types.IntAttribute{
    .name = "azure.cosmosdb.response.sub_status_code",
    .brief = "Cosmos DB sub status code.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// [Azure Resource Provider Namespace](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers) as recognized by the client.
///
/// # Examples
///
/// - Microsoft.DocumentDB
/// Note: This attribute is experimental and may change in the future.
pub const azure_resource_provider_namespace = types.StringAttribute{
    .name = "azure.resource_provider.namespace",
    .brief = "[Azure Resource Provider Namespace](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers) as recognized by the client.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The unique identifier of the service request. It's generated by the Azure service and returned with the response.
///
/// # Examples
///
/// - 00000000-0000-0000-0000-000000000000
/// Note: This attribute is experimental and may change in the future.
pub const azure_service_request_id = types.StringAttribute{
    .name = "azure.service.request.id",
    .brief = "The unique identifier of the service request. It's generated by the Azure service and returned with the response.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The consistency level of the query. Based on consistency values from [CQL](https://docs.datastax.com/en/cassandra-oss/3.0/cassandra/dml/dmlConfigConsistency.html).
/// Note: This attribute is experimental and may change in the future.
pub const cassandra_consistency_level = types.StringAttribute{
    .name = "cassandra.consistency.level",
    .brief = "The consistency level of the query. Based on consistency values from [CQL](https://docs.datastax.com/en/cassandra-oss/3.0/cassandra/dml/dmlConfigConsistency.html).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The data center of the coordinating node for a query.
///
/// # Examples
///
/// - us-west-2
/// Note: This attribute is experimental and may change in the future.
pub const cassandra_coordinator_dc = types.StringAttribute{
    .name = "cassandra.coordinator.dc",
    .brief = "The data center of the coordinating node for a query.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The ID of the coordinating node for a query.
///
/// # Examples
///
/// - be13faa2-8574-4d71-926d-27f16cf8a7af
/// Note: This attribute is experimental and may change in the future.
pub const cassandra_coordinator_id = types.StringAttribute{
    .name = "cassandra.coordinator.id",
    .brief = "The ID of the coordinating node for a query.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The fetch size used for paging, i.e. how many rows will be returned at once.
///
/// # Examples
///
/// - 5000
/// Note: This attribute is experimental and may change in the future.
pub const cassandra_page_size = types.IntAttribute{
    .name = "cassandra.page.size",
    .brief = "The fetch size used for paging, i.e. how many rows will be returned at once.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Whether or not the query is idempotent.
/// Note: This attribute is experimental and may change in the future.
pub const cassandra_query_idempotent = types.BooleanAttribute{
    .name = "cassandra.query.idempotent",
    .brief = "Whether or not the query is idempotent.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The number of times a query was speculatively executed. Not set or `0` if the query was not executed speculatively.
///
/// # Examples
///
/// - 0
/// - 2
/// Note: This attribute is experimental and may change in the future.
pub const cassandra_speculative_execution_count = types.IntAttribute{
    .name = "cassandra.speculative_execution.count",
    .brief = "The number of times a query was speculatively executed. Not set or `0` if the query was not executed speculatively.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The kind of action a pipeline run is performing.
///
/// # Examples
///
/// - BUILD
/// - RUN
/// - SYNC
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_action_name = types.StringAttribute{
    .name = "cicd.pipeline.action.name",
    .brief = "The kind of action a pipeline run is performing.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The result of a pipeline run.
///
/// # Examples
///
/// - success
/// - failure
/// - timeout
/// - skipped
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_result = types.StringAttribute{
    .name = "cicd.pipeline.result",
    .brief = "The result of a pipeline run.",
    .stability = .development,
    .requirement_level = .required,
};

/// The human readable name of a task within a pipeline. Task here most closely aligns with a [computing process](https://wikipedia.org/wiki/Pipeline_(computing)) in a pipeline. Other terms for tasks include commands, steps, and procedures.
///
/// # Examples
///
/// - Run GoLang Linter
/// - Go Build
/// - go-test
/// - deploy_binary
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_task_name = types.StringAttribute{
    .name = "cicd.pipeline.task.name",
    .brief = "The human readable name of a task within a pipeline. Task here most closely aligns with a [computing process](https://wikipedia.org/wiki/Pipeline_(computing)) in a pipeline. Other terms for tasks include commands, steps, and procedures.",
    .stability = .development,
    .requirement_level = .required,
};

/// The unique identifier of a task run within a pipeline.
///
/// # Examples
///
/// - 12097
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_task_run_id = types.StringAttribute{
    .name = "cicd.pipeline.task.run.id",
    .brief = "The unique identifier of a task run within a pipeline.",
    .stability = .development,
    .requirement_level = .required,
};

/// The result of a task run.
///
/// # Examples
///
/// - success
/// - failure
/// - timeout
/// - skipped
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_task_run_result = types.StringAttribute{
    .name = "cicd.pipeline.task.run.result",
    .brief = "The result of a task run.",
    .stability = .development,
    .requirement_level = .required,
};

/// The [URL](https://wikipedia.org/wiki/URL) of the pipeline task run, providing the complete address in order to locate and identify the pipeline task run.
///
/// # Examples
///
/// - https://github.com/open-telemetry/semantic-conventions/actions/runs/9753949763/job/26920038674?pr=1075
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_task_run_url_full = types.StringAttribute{
    .name = "cicd.pipeline.task.run.url.full",
    .brief = "The [URL](https://wikipedia.org/wiki/URL) of the pipeline task run, providing the complete address in order to locate and identify the pipeline task run.",
    .stability = .development,
    .requirement_level = .required,
};

/// Client address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.
///
/// # Examples
///
/// - 83.164.160.102
pub const client_address = types.StringAttribute{
    .name = "client.address",
    .brief = "Client address - domain name if available without reverse DNS lookup; otherwise, IP address or Unix domain socket name.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The port of whichever client was captured in `client.address`.
///
/// # Examples
///
/// - 65123
pub const client_port = types.IntAttribute{
    .name = "client.port",
    .brief = "The port of whichever client was captured in `client.address`.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The AWS Region where the requested service is being accessed.
///
/// # Examples
///
/// - us-east-1
/// - us-west-2
/// Note: This attribute is experimental and may change in the future.
pub const cloud_region = types.StringAttribute{
    .name = "cloud.region",
    .brief = "The AWS Region where the requested service is being accessed.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The [Fully Qualified Azure Resource ID](https://learn.microsoft.com/rest/api/resources/resources/get-by-id) the log is emitted for.
///
/// # Examples
///
/// - arn:aws:lambda:REGION:ACCOUNT_ID:function:my-function
/// - //run.googleapis.com/projects/PROJECT_ID/locations/LOCATION_ID/services/SERVICE_ID
/// - /subscriptions/<SUBSCRIPTION_GUID>/resourceGroups/<RG>/providers/Microsoft.Web/sites/<FUNCAPP>/functions/<FUNC>
/// Note: This attribute is experimental and may change in the future.
pub const cloud_resource_id = types.StringAttribute{
    .name = "cloud.resource_id",
    .brief = "The [Fully Qualified Azure Resource ID](https://learn.microsoft.com/rest/api/resources/resources/get-by-id) the log is emitted for.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Cosmos DB container name.
///
/// # Examples
///
/// - public.users
/// - customers
pub const db_collection_name = types.StringAttribute{
    .name = "db.collection.name",
    .brief = "Cosmos DB container name.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The name of the database, fully qualified within the server address and port.
///
/// # Examples
///
/// - customers
/// - test.users
pub const db_namespace = types.StringAttribute{
    .name = "db.namespace",
    .brief = "The name of the database, fully qualified within the server address and port.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The number of queries included in a batch operation.
///
/// # Examples
///
/// - 2
/// - 3
/// - 4
pub const db_operation_batch_size = types.IntAttribute{
    .name = "db.operation.batch.size",
    .brief = "The number of queries included in a batch operation.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The name of the operation or command being executed.
///
/// # Examples
///
/// - create_item
/// - query_items
/// - read_item
pub const db_operation_name = types.StringAttribute{
    .name = "db.operation.name",
    .brief = "The name of the operation or command being executed.",
    .stability = .stable,
    .requirement_level = .required,
};

/// A dynamic value in the url path.
///
/// # Examples
///
/// - db.operation.parameter.index=\"test-index\"
/// - db.operation.parameter=\"123\"
/// Note: This attribute is experimental and may change in the future.
pub const db_operation_parameter = types.StringAttribute{
    .name = "db.operation.parameter",
    .brief = "A dynamic value in the url path.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// A database query parameter, with `<key>` being the parameter name, and the attribute value being a string representation of the parameter value.
///
/// # Examples
///
/// - someval
/// - 55
/// Note: This attribute is experimental and may change in the future.
pub const db_query_parameter = types.StringAttribute{
    .name = "db.query.parameter",
    .brief = "A database query parameter, with `<key>` being the parameter name, and the attribute value being a string representation of the parameter value.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Low cardinality summary of a database query.
///
/// # Examples
///
/// - SELECT wuser_table
/// - INSERT shipping_details SELECT orders
/// - get user by id
pub const db_query_summary = types.StringAttribute{
    .name = "db.query.summary",
    .brief = "Low cardinality summary of a database query.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The database query being executed.
///
/// # Examples
///
/// - SELECT * FROM wuser_table where username = ?
/// - SET mykey ?
pub const db_query_text = types.StringAttribute{
    .name = "db.query.text",
    .brief = "The database query being executed.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// Cosmos DB row count in result set.
///
/// # Examples
///
/// - 10
/// - 20
/// Note: This attribute is experimental and may change in the future.
pub const db_response_returned_rows = types.IntAttribute{
    .name = "db.response.returned_rows",
    .brief = "Cosmos DB row count in result set.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Cosmos DB status code.
///
/// # Examples
///
/// - 200
/// - 201
pub const db_response_status_code = types.StringAttribute{
    .name = "db.response.status_code",
    .brief = "Cosmos DB status code.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The name of a stored procedure within the database.
///
/// # Examples
///
/// - GetCustomer
pub const db_stored_procedure_name = types.StringAttribute{
    .name = "db.stored_procedure.name",
    .brief = "The name of a stored procedure within the database.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The database management system (DBMS) product as identified by the client instrumentation.
pub const db_system_name = types.StringAttribute{
    .name = "db.system.name",
    .brief = "The database management system (DBMS) product as identified by the client instrumentation.",
    .stability = .stable,
    .requirement_level = .required,
};

/// List of resolved IP addresses (for DNS lookup) or a single element containing domain name (for reverse lookup).
///
/// # Examples
///
/// - [\"10.0.0.1\", \"2001:0db8:85a3:0000:0000:8a2e:0370:7334\"]
/// Note: This attribute is experimental and may change in the future.
pub const dns_answers = types.StringArrayAttribute{
    .name = "dns.answers",
    .brief = "List of resolved IP addresses (for DNS lookup) or a single element containing domain name (for reverse lookup).",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The domain name or an IP address being queried.
///
/// # Examples
///
/// - www.example.com
/// - opentelemetry.io
/// Note: This attribute is experimental and may change in the future.
pub const dns_question_name = types.StringAttribute{
    .name = "dns.question.name",
    .brief = "The domain name or an IP address being queried.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Represents the human-readable identifier of the node/instance to which a request was routed.
///
/// # Examples
///
/// - instance-0000000001
/// Note: This attribute is experimental and may change in the future.
pub const elasticsearch_node_name = types.StringAttribute{
    .name = "elasticsearch.node.name",
    .brief = "Represents the human-readable identifier of the node/instance to which a request was routed.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A message providing more detail about an error in human-readable form.
///
/// # Examples
///
/// - Unexpected input type: string
/// - The user has exceeded their storage quota
/// Note: This attribute is experimental and may change in the future.
pub const error_message = types.StringAttribute{
    .name = "error.message",
    .brief = "A message providing more detail about an error in human-readable form.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Describes a class of error the operation ended with.
///
/// # Examples
///
/// - timeout
/// - java.net.UnknownHostException
/// - server_certificate_invalid
/// - 500
pub const error_type = types.StringAttribute{
    .name = "error.type",
    .brief = "Describes a class of error the operation ended with.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// Indicates that the exception is escaping the scope of the span.
/// Note: This attribute is deprecated. {"note": "It's no longer recommended to record exceptions that are handled and do not escape the scope of a span.\n", "reason": "obsoleted"}
pub const exception_escaped = types.BooleanAttribute{
    .name = "exception.escaped",
    .brief = "Indicates that the exception is escaping the scope of the span.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The exception message.
///
/// # Examples
///
/// - Division by zero
/// - Can't convert 'int' object to str implicitly
pub const exception_message = types.StringAttribute{
    .name = "exception.message",
    .brief = "The exception message.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// A stacktrace as a string in the natural representation for the language runtime. The representation is to be determined and documented by each language SIG.
///
/// # Examples
///
/// - Exception in thread \"main\" java.lang.RuntimeException: Test exception\n at com.example.GenerateTrace.methodB(GenerateTrace.java:13)\n at com.example.GenerateTrace.methodA(GenerateTrace.java:9)\n at com.example.GenerateTrace.main(GenerateTrace.java:5)\n
pub const exception_stacktrace = types.StringAttribute{
    .name = "exception.stacktrace",
    .brief = "A stacktrace as a string in the natural representation for the language runtime. The representation is to be determined and documented by each language SIG.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The type of the exception (its fully-qualified class name, if applicable). The dynamic type of the exception should be preferred over the static type in languages that support it.
///
/// # Examples
///
/// - java.net.ConnectException
/// - OSError
pub const exception_type = types.StringAttribute{
    .name = "exception.type",
    .brief = "The type of the exception (its fully-qualified class name, if applicable). The dynamic type of the exception should be preferred over the static type in languages that support it.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// A boolean that is true if the serverless function is executed for the first time (aka cold-start).
/// Note: This attribute is experimental and may change in the future.
pub const faas_coldstart = types.BooleanAttribute{
    .name = "faas.coldstart",
    .brief = "A boolean that is true if the serverless function is executed for the first time (aka cold-start).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A string containing the schedule period as [Cron Expression](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm).
///
/// # Examples
///
/// - 0/5 * * * ? *
/// Note: This attribute is experimental and may change in the future.
pub const faas_cron = types.StringAttribute{
    .name = "faas.cron",
    .brief = "A string containing the schedule period as [Cron Expression](https://docs.oracle.com/cd/E12058_01/doc/doc.1014/e12030/cron_expressions.htm).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the source on which the triggering operation was performed. For example, in Cloud Storage or S3 corresponds to the bucket name, and in Cosmos DB to the database name.
///
/// # Examples
///
/// - myBucketName
/// - myDbName
/// Note: This attribute is experimental and may change in the future.
pub const faas_document_collection = types.StringAttribute{
    .name = "faas.document.collection",
    .brief = "The name of the source on which the triggering operation was performed. For example, in Cloud Storage or S3 corresponds to the bucket name, and in Cosmos DB to the database name.",
    .stability = .development,
    .requirement_level = .required,
};

/// The document name/table subjected to the operation. For example, in Cloud Storage or S3 is the name of the file, and in Cosmos DB the table name.
///
/// # Examples
///
/// - myFile.txt
/// - myTableName
/// Note: This attribute is experimental and may change in the future.
pub const faas_document_name = types.StringAttribute{
    .name = "faas.document.name",
    .brief = "The document name/table subjected to the operation. For example, in Cloud Storage or S3 is the name of the file, and in Cosmos DB the table name.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Describes the type of the operation that was performed on the data.
/// Note: This attribute is experimental and may change in the future.
pub const faas_document_operation = types.StringAttribute{
    .name = "faas.document.operation",
    .brief = "Describes the type of the operation that was performed on the data.",
    .stability = .development,
    .requirement_level = .required,
};

/// A string containing the time when the data was accessed in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).
///
/// # Examples
///
/// - 2020-01-23T13:47:06Z
/// Note: This attribute is experimental and may change in the future.
pub const faas_document_time = types.StringAttribute{
    .name = "faas.document.time",
    .brief = "A string containing the time when the data was accessed in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the invoked function.
///
/// # Examples
///
/// - my-function
/// Note: This attribute is experimental and may change in the future.
pub const faas_invoked_name = types.StringAttribute{
    .name = "faas.invoked_name",
    .brief = "The name of the invoked function.",
    .stability = .development,
    .requirement_level = .required,
};

/// The cloud provider of the invoked function.
/// Note: This attribute is experimental and may change in the future.
pub const faas_invoked_provider = types.StringAttribute{
    .name = "faas.invoked_provider",
    .brief = "The cloud provider of the invoked function.",
    .stability = .development,
    .requirement_level = .required,
};

/// The cloud region of the invoked function.
///
/// # Examples
///
/// - eu-central-1
/// Note: This attribute is experimental and may change in the future.
pub const faas_invoked_region = types.StringAttribute{
    .name = "faas.invoked_region",
    .brief = "The cloud region of the invoked function.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// A string containing the function invocation time in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).
///
/// # Examples
///
/// - 2020-01-23T13:47:06Z
/// Note: This attribute is experimental and may change in the future.
pub const faas_time = types.StringAttribute{
    .name = "faas.time",
    .brief = "A string containing the function invocation time in the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) format expressed in [UTC](https://www.w3.org/TR/NOTE-datetime).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Type of the trigger which caused this function invocation.
/// Note: This attribute is experimental and may change in the future.
pub const faas_trigger = types.StringAttribute{
    .name = "faas.trigger",
    .brief = "Type of the trigger which caused this function invocation.",
    .stability = .development,
    .requirement_level = .required,
};

/// The unique identifier for the flag evaluation context. For example, the targeting key.
///
/// # Examples
///
/// - 5157782b-2203-4c80-a857-dbbd5e7761db
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_context_id = types.StringAttribute{
    .name = "feature_flag.context.id",
    .brief = "The unique identifier for the flag evaluation context. For example, the targeting key.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The lookup key of the feature flag.
///
/// # Examples
///
/// - logo-color
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_key = types.StringAttribute{
    .name = "feature_flag.key",
    .brief = "The lookup key of the feature flag.",
    .stability = .development,
    .requirement_level = .required,
};

/// Identifies the feature flag provider.
///
/// # Examples
///
/// - Flag Manager
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_provider_name = types.StringAttribute{
    .name = "feature_flag.provider.name",
    .brief = "Identifies the feature flag provider.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The reason code which shows how a feature flag value was determined.
///
/// # Examples
///
/// - static
/// - targeting_match
/// - error
/// - default
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_result_reason = types.StringAttribute{
    .name = "feature_flag.result.reason",
    .brief = "The reason code which shows how a feature flag value was determined.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The evaluated value of the feature flag.
///
/// # Examples
///
/// - #ff0000
/// - true
/// - 3
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_result_value = types.StringAttribute{
    .name = "feature_flag.result.value",
    .brief = "The evaluated value of the feature flag.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// A semantic identifier for an evaluated flag value.
///
/// # Examples
///
/// - red
/// - true
/// - on
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_result_variant = types.StringAttribute{
    .name = "feature_flag.result.variant",
    .brief = "A semantic identifier for an evaluated flag value.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The identifier of the [flag set](https://openfeature.dev/specification/glossary/#flag-set) to which the feature flag belongs.
///
/// # Examples
///
/// - proj-1
/// - ab98sgs
/// - service1/dev
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_set_id = types.StringAttribute{
    .name = "feature_flag.set.id",
    .brief = "The identifier of the [flag set](https://openfeature.dev/specification/glossary/#flag-set) to which the feature flag belongs.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The version of the ruleset used during the evaluation. This may be any stable value which uniquely identifies the ruleset.
///
/// # Examples
///
/// - 1
/// - 01ABCDEF
/// Note: This attribute is experimental and may change in the future.
pub const feature_flag_version = types.StringAttribute{
    .name = "feature_flag.version",
    .brief = "The version of the ruleset used during the evaluation. This may be any stable value which uniquely identifies the ruleset.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Free-form description of the GenAI agent provided by the application.
///
/// # Examples
///
/// - Helps with math problems
/// - Generates fiction stories
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_agent_description = types.StringAttribute{
    .name = "gen_ai.agent.description",
    .brief = "Free-form description of the GenAI agent provided by the application.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The unique identifier of the GenAI agent.
///
/// # Examples
///
/// - asst_5j66UpCpwteGg4YSxUnt7lPY
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_agent_id = types.StringAttribute{
    .name = "gen_ai.agent.id",
    .brief = "The unique identifier of the GenAI agent.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Human-readable name of the GenAI agent provided by the application.
///
/// # Examples
///
/// - Math Tutor
/// - Fiction Writer
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_agent_name = types.StringAttribute{
    .name = "gen_ai.agent.name",
    .brief = "Human-readable name of the GenAI agent provided by the application.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The unique identifier for a conversation (session, thread), used to store and correlate messages within this conversation.
///
/// # Examples
///
/// - conv_5j66UpCpwteGg4YSxUnt7lPY
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_conversation_id = types.StringAttribute{
    .name = "gen_ai.conversation.id",
    .brief = "The unique identifier for a conversation (session, thread), used to store and correlate messages within this conversation.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The data source identifier.
///
/// # Examples
///
/// - H7STPQYOND
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_data_source_id = types.StringAttribute{
    .name = "gen_ai.data_source.id",
    .brief = "The data source identifier.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The service tier requested. May be a specific tier, default, or auto.
///
/// # Examples
///
/// - auto
/// - default
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_openai_request_service_tier = types.StringAttribute{
    .name = "gen_ai.openai.request.service_tier",
    .brief = "The service tier requested. May be a specific tier, default, or auto.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The service tier used for the response.
///
/// # Examples
///
/// - scale
/// - default
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_openai_response_service_tier = types.StringAttribute{
    .name = "gen_ai.openai.response.service_tier",
    .brief = "The service tier used for the response.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// A fingerprint to track any eventual change in the Generative AI environment.
///
/// # Examples
///
/// - fp_44709d6fcb
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_openai_response_system_fingerprint = types.StringAttribute{
    .name = "gen_ai.openai.response.system_fingerprint",
    .brief = "A fingerprint to track any eventual change in the Generative AI environment.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the operation being performed.
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_operation_name = types.StringAttribute{
    .name = "gen_ai.operation.name",
    .brief = "The name of the operation being performed.",
    .stability = .development,
    .requirement_level = .required,
};

/// Represents the content type requested by the client.
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_output_type = types.StringAttribute{
    .name = "gen_ai.output.type",
    .brief = "Represents the content type requested by the client.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The target number of candidate completions to return.
///
/// # Examples
///
/// - 3
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_choice_count = types.IntAttribute{
    .name = "gen_ai.request.choice.count",
    .brief = "The target number of candidate completions to return.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The encoding formats requested in an embeddings operation, if specified.
///
/// # Examples
///
/// - [\"base64\"]
/// - [\"float\", \"binary\"]
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_encoding_formats = types.StringArrayAttribute{
    .name = "gen_ai.request.encoding_formats",
    .brief = "The encoding formats requested in an embeddings operation, if specified.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The frequency penalty setting for the GenAI request.
///
/// # Examples
///
/// - 0.1
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_frequency_penalty = types.DoubleAttribute{
    .name = "gen_ai.request.frequency_penalty",
    .brief = "The frequency penalty setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The maximum number of tokens the model generates for a request.
///
/// # Examples
///
/// - 100
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_max_tokens = types.IntAttribute{
    .name = "gen_ai.request.max_tokens",
    .brief = "The maximum number of tokens the model generates for a request.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the GenAI model a request is being made to.
///
/// # Examples
///
/// - gpt-4
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_model = types.StringAttribute{
    .name = "gen_ai.request.model",
    .brief = "The name of the GenAI model a request is being made to.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The presence penalty setting for the GenAI request.
///
/// # Examples
///
/// - 0.1
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_presence_penalty = types.DoubleAttribute{
    .name = "gen_ai.request.presence_penalty",
    .brief = "The presence penalty setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Requests with same seed value more likely to return same result.
///
/// # Examples
///
/// - 100
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_seed = types.IntAttribute{
    .name = "gen_ai.request.seed",
    .brief = "Requests with same seed value more likely to return same result.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// List of sequences that the model will use to stop generating further tokens.
///
/// # Examples
///
/// - [\"forest\", \"lived\"]
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_stop_sequences = types.StringArrayAttribute{
    .name = "gen_ai.request.stop_sequences",
    .brief = "List of sequences that the model will use to stop generating further tokens.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The temperature setting for the GenAI request.
///
/// # Examples
///
/// - 0.0
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_temperature = types.DoubleAttribute{
    .name = "gen_ai.request.temperature",
    .brief = "The temperature setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The top_k sampling setting for the GenAI request.
///
/// # Examples
///
/// - 1.0
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_top_k = types.DoubleAttribute{
    .name = "gen_ai.request.top_k",
    .brief = "The top_k sampling setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The top_p sampling setting for the GenAI request.
///
/// # Examples
///
/// - 1.0
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_request_top_p = types.DoubleAttribute{
    .name = "gen_ai.request.top_p",
    .brief = "The top_p sampling setting for the GenAI request.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Array of reasons the model stopped generating tokens, corresponding to each generation received.
///
/// # Examples
///
/// - [\"stop\"]
/// - [\"stop\", \"length\"]
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_response_finish_reasons = types.StringArrayAttribute{
    .name = "gen_ai.response.finish_reasons",
    .brief = "Array of reasons the model stopped generating tokens, corresponding to each generation received.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The unique identifier for the completion.
///
/// # Examples
///
/// - chatcmpl-123
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_response_id = types.StringAttribute{
    .name = "gen_ai.response.id",
    .brief = "The unique identifier for the completion.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the model that generated the response.
///
/// # Examples
///
/// - gpt-4-0613
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_response_model = types.StringAttribute{
    .name = "gen_ai.response.model",
    .brief = "The name of the model that generated the response.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The Generative AI product as identified by the client or server instrumentation.
///
/// # Examples
///
/// - openai
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_system = types.StringAttribute{
    .name = "gen_ai.system",
    .brief = "The Generative AI product as identified by the client or server instrumentation.",
    .stability = .development,
    .requirement_level = .required,
};

/// The tool call identifier.
///
/// # Examples
///
/// - call_mszuSIzqtI65i1wAUOE8w5H4
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_tool_call_id = types.StringAttribute{
    .name = "gen_ai.tool.call.id",
    .brief = "The tool call identifier.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The tool description.
///
/// # Examples
///
/// - Multiply two numbers
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_tool_description = types.StringAttribute{
    .name = "gen_ai.tool.description",
    .brief = "The tool description.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Name of the tool utilized by the agent.
///
/// # Examples
///
/// - Flights
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_tool_name = types.StringAttribute{
    .name = "gen_ai.tool.name",
    .brief = "Name of the tool utilized by the agent.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The number of tokens used in the GenAI input (prompt).
///
/// # Examples
///
/// - 100
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_usage_input_tokens = types.IntAttribute{
    .name = "gen_ai.usage.input_tokens",
    .brief = "The number of tokens used in the GenAI input (prompt).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The number of tokens used in the GenAI response (completion).
///
/// # Examples
///
/// - 180
/// Note: This attribute is experimental and may change in the future.
pub const gen_ai_usage_output_tokens = types.IntAttribute{
    .name = "gen_ai.usage.output_tokens",
    .brief = "The number of tokens used in the GenAI response (completion).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The GraphQL document being executed.
///
/// # Examples
///
/// - query findBookById { bookById(id: ?) { name } }
/// Note: This attribute is experimental and may change in the future.
pub const graphql_document = types.StringAttribute{
    .name = "graphql.document",
    .brief = "The GraphQL document being executed.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the operation being executed.
///
/// # Examples
///
/// - findBookById
/// Note: This attribute is experimental and may change in the future.
pub const graphql_operation_name = types.StringAttribute{
    .name = "graphql.operation.name",
    .brief = "The name of the operation being executed.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The type of the operation being executed.
///
/// # Examples
///
/// - query
/// - mutation
/// - subscription
/// Note: This attribute is experimental and may change in the future.
pub const graphql_operation_type = types.StringAttribute{
    .name = "graphql.operation.type",
    .brief = "The type of the operation being executed.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
///
/// # Examples
///
/// - 3495
/// Note: This attribute is experimental and may change in the future.
pub const http_request_body_size = types.IntAttribute{
    .name = "http.request.body.size",
    .brief = "The size of the request payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// HTTP request headers, `<key>` being the normalized HTTP Header name (lowercase), the value being the header values.
///
/// # Examples
///
/// - [\"application/json\"]
/// - [\"1.2.3.4\", \"1.2.3.5\"]
pub const http_request_header = types.StringArrayAttribute{
    .name = "http.request.header",
    .brief = "HTTP request headers, `<key>` being the normalized HTTP Header name (lowercase), the value being the header values.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// HTTP request method.
///
/// # Examples
///
/// - GET
/// - POST
/// - HEAD
pub const http_request_method = types.StringAttribute{
    .name = "http.request.method",
    .brief = "HTTP request method.",
    .stability = .stable,
    .requirement_level = .required,
};

/// Original HTTP method sent by the client in the request line.
///
/// # Examples
///
/// - GeT
/// - ACL
/// - foo
pub const http_request_method_original = types.StringAttribute{
    .name = "http.request.method_original",
    .brief = "Original HTTP method sent by the client in the request line.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The ordinal number of request resending attempt (for any reason, including redirects).
///
/// # Examples
///
/// - 3
pub const http_request_resend_count = types.IntAttribute{
    .name = "http.request.resend_count",
    .brief = "The ordinal number of request resending attempt (for any reason, including redirects).",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The total size of the request in bytes. This should be the total number of bytes sent over the wire, including the request line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and request body if any.
///
/// # Examples
///
/// - 1437
/// Note: This attribute is experimental and may change in the future.
pub const http_request_size = types.IntAttribute{
    .name = "http.request.size",
    .brief = "The total size of the request in bytes. This should be the total number of bytes sent over the wire, including the request line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and request body if any.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.
///
/// # Examples
///
/// - 3495
/// Note: This attribute is experimental and may change in the future.
pub const http_response_body_size = types.IntAttribute{
    .name = "http.response.body.size",
    .brief = "The size of the response payload body in bytes. This is the number of bytes transferred excluding headers and is often, but not always, present as the [Content-Length](https://www.rfc-editor.org/rfc/rfc9110.html#field.content-length) header. For requests using transport encoding, this should be the compressed size.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// HTTP response headers, `<key>` being the normalized HTTP Header name (lowercase), the value being the header values.
///
/// # Examples
///
/// - [\"application/json\"]
/// - [\"abc\", \"def\"]
pub const http_response_header = types.StringArrayAttribute{
    .name = "http.response.header",
    .brief = "HTTP response headers, `<key>` being the normalized HTTP Header name (lowercase), the value being the header values.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The total size of the response in bytes. This should be the total number of bytes sent over the wire, including the status line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and response body and trailers if any.
///
/// # Examples
///
/// - 1437
/// Note: This attribute is experimental and may change in the future.
pub const http_response_size = types.IntAttribute{
    .name = "http.response.size",
    .brief = "The total size of the response in bytes. This should be the total number of bytes sent over the wire, including the status line (HTTP/1.1), framing (HTTP/2 and HTTP/3), headers, and response body and trailers if any.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// [HTTP response status code](https://tools.ietf.org/html/rfc7231#section-6).
///
/// # Examples
///
/// - 200
pub const http_response_status_code = types.IntAttribute{
    .name = "http.response.status_code",
    .brief = "[HTTP response status code](https://tools.ietf.org/html/rfc7231#section-6).",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The matched route, that is, the path template in the format used by the respective server framework.
///
/// # Examples
///
/// - /users/:userID?
/// - {controller}/{action}/{id?}
pub const http_route = types.StringAttribute{
    .name = "http.route",
    .brief = "The matched route, that is, the path template in the format used by the respective server framework.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// This attribute represents the state of the application.
/// Note: This attribute is experimental and may change in the future.
pub const ios_app_state = types.StringAttribute{
    .name = "ios.app.state",
    .brief = "This attribute represents the state of the application.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Local socket address. Useful in case of a multi-IP host.
///
/// # Examples
///
/// - 10.1.2.80
/// - /tmp/my.sock
pub const network_local_address = types.StringAttribute{
    .name = "network.local.address",
    .brief = "Local socket address. Useful in case of a multi-IP host.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// Local socket port. Useful in case of a multi-port host.
///
/// # Examples
///
/// - 65123
pub const network_local_port = types.IntAttribute{
    .name = "network.local.port",
    .brief = "Local socket port. Useful in case of a multi-port host.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// Peer address of the database node where the operation was performed.
///
/// # Examples
///
/// - 10.1.2.80
/// - /tmp/my.sock
pub const network_peer_address = types.StringAttribute{
    .name = "network.peer.address",
    .brief = "Peer address of the database node where the operation was performed.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// Peer port number of the network connection.
///
/// # Examples
///
/// - 65123
pub const network_peer_port = types.IntAttribute{
    .name = "network.peer.port",
    .brief = "Peer port number of the network connection.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// [OSI application layer](https://wikipedia.org/wiki/Application_layer) or non-OSI equivalent.
///
/// # Examples
///
/// - http
/// - spdy
pub const network_protocol_name = types.StringAttribute{
    .name = "network.protocol.name",
    .brief = "[OSI application layer](https://wikipedia.org/wiki/Application_layer) or non-OSI equivalent.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The actual version of the protocol used for network communication.
///
/// # Examples
///
/// - 1.0
/// - 1.1
/// - 2
/// - 3
pub const network_protocol_version = types.StringAttribute{
    .name = "network.protocol.version",
    .brief = "The actual version of the protocol used for network communication.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// [OSI transport layer](https://wikipedia.org/wiki/Transport_layer) or [inter-process communication method](https://wikipedia.org/wiki/Inter-process_communication).
///
/// # Examples
///
/// - tcp
/// - udp
/// - unix
pub const network_transport = types.StringAttribute{
    .name = "network.transport",
    .brief = "[OSI transport layer](https://wikipedia.org/wiki/Transport_layer) or [inter-process communication method](https://wikipedia.org/wiki/Inter-process_communication).",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// [OSI network layer](https://wikipedia.org/wiki/Network_layer) or non-OSI equivalent.
///
/// # Examples
///
/// - ipv4
/// - ipv6
pub const network_type = types.StringAttribute{
    .name = "network.type",
    .brief = "[OSI network layer](https://wikipedia.org/wiki/Network_layer) or non-OSI equivalent.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// All the command arguments (including the command/executable itself) as received by the process. On Linux-based systems (and some other Unixoid systems supporting procfs), can be set according to the list of null-delimited strings extracted from `proc/[pid]/cmdline`. For libc-based executables, this would be the full argv vector passed to `main`. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.
///
/// # Examples
///
/// - [\"cmd/otecol\", \"--config=config.yaml\"]
/// Note: This attribute is experimental and may change in the future.
pub const process_command_args = types.StringArrayAttribute{
    .name = "process.command_args",
    .brief = "All the command arguments (including the command/executable itself) as received by the process. On Linux-based systems (and some other Unixoid systems supporting procfs), can be set according to the list of null-delimited strings extracted from `proc/[pid]/cmdline`. For libc-based executables, this would be the full argv vector passed to `main`. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the process executable. On Linux based systems, this SHOULD be set to the base name of the target of `/proc/[pid]/exe`. On Windows, this SHOULD be set to the base name of `GetProcessImageFileNameW`.
///
/// # Examples
///
/// - otelcol
/// Note: This attribute is experimental and may change in the future.
pub const process_executable_name = types.StringAttribute{
    .name = "process.executable.name",
    .brief = "The name of the process executable. On Linux based systems, this SHOULD be set to the base name of the target of `/proc/[pid]/exe`. On Windows, this SHOULD be set to the base name of `GetProcessImageFileNameW`.",
    .stability = .development,
    .requirement_level = .required,
};

/// The full path to the process executable. On Linux based systems, can be set to the target of `proc/[pid]/exe`. On Windows, can be set to the result of `GetProcessImageFileNameW`.
///
/// # Examples
///
/// - /usr/bin/cmd/otelcol
/// Note: This attribute is experimental and may change in the future.
pub const process_executable_path = types.StringAttribute{
    .name = "process.executable.path",
    .brief = "The full path to the process executable. On Linux based systems, can be set to the target of `proc/[pid]/exe`. On Windows, can be set to the result of `GetProcessImageFileNameW`.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The exit code of the process.
///
/// # Examples
///
/// - 127
/// Note: This attribute is experimental and may change in the future.
pub const process_exit_code = types.IntAttribute{
    .name = "process.exit.code",
    .brief = "The exit code of the process.",
    .stability = .development,
    .requirement_level = .required,
};

/// Process identifier (PID).
///
/// # Examples
///
/// - 1234
/// Note: This attribute is experimental and may change in the future.
pub const process_pid = types.IntAttribute{
    .name = "process.pid",
    .brief = "Process identifier (PID).",
    .stability = .development,
    .requirement_level = .required,
};

/// Compressed size of the message in bytes.
/// Note: This attribute is experimental and may change in the future.
pub const rpc_message_compressed_size = types.IntAttribute{
    .name = "rpc.message.compressed_size",
    .brief = "Compressed size of the message in bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// MUST be calculated as two different counters starting from `1` one for sent messages and one for received message.
/// Note: This attribute is experimental and may change in the future.
pub const rpc_message_id = types.IntAttribute{
    .name = "rpc.message.id",
    .brief = "MUST be calculated as two different counters starting from `1` one for sent messages and one for received message.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Whether this is a received or sent message.
/// Note: This attribute is experimental and may change in the future.
pub const rpc_message_type = types.StringAttribute{
    .name = "rpc.message.type",
    .brief = "Whether this is a received or sent message.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Uncompressed size of the message in bytes.
/// Note: This attribute is experimental and may change in the future.
pub const rpc_message_uncompressed_size = types.IntAttribute{
    .name = "rpc.message.uncompressed_size",
    .brief = "Uncompressed size of the message in bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the operation corresponding to the request, as returned by the AWS SDK
///
/// # Examples
///
/// - GetItem
/// - PutItem
/// Note: This attribute is experimental and may change in the future.
pub const rpc_method = types.StringAttribute{
    .name = "rpc.method",
    .brief = "The name of the operation corresponding to the request, as returned by the AWS SDK",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the service to which a request is made, as returned by the AWS SDK.
///
/// # Examples
///
/// - DynamoDB
/// - S3
/// Note: This attribute is experimental and may change in the future.
pub const rpc_service = types.StringAttribute{
    .name = "rpc.service",
    .brief = "The name of the service to which a request is made, as returned by the AWS SDK.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The value `aws-api`.
///
/// # Examples
///
/// - aws-api
/// Note: This attribute is experimental and may change in the future.
pub const rpc_system = types.StringAttribute{
    .name = "rpc.system",
    .brief = "The value `aws-api`.",
    .stability = .development,
    .requirement_level = .required,
};

/// GenAI server address.
///
/// # Examples
///
/// - example.com
/// - 10.1.2.80
/// - /tmp/my.sock
pub const server_address = types.StringAttribute{
    .name = "server.address",
    .brief = "GenAI server address.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// GenAI server port.
///
/// # Examples
///
/// - 80
/// - 8080
/// - 443
pub const server_port = types.IntAttribute{
    .name = "server.port",
    .brief = "GenAI server port.",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The ID of the new session being started.
///
/// # Examples
///
/// - 00112233-4455-6677-8899-aabbccddeeff
/// Note: This attribute is experimental and may change in the future.
pub const session_id = types.StringAttribute{
    .name = "session.id",
    .brief = "The ID of the new session being started.",
    .stability = .development,
    .requirement_level = .required,
};

/// The previous `session.id` for this user, when known.
///
/// # Examples
///
/// - 00112233-4455-6677-8899-aabbccddeeff
/// Note: This attribute is experimental and may change in the future.
pub const session_previous_id = types.StringAttribute{
    .name = "session.previous_id",
    .brief = "The previous `session.id` for this user, when known.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Normalized lowercase protocol name parsed from original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)
/// Note: This attribute is experimental and may change in the future.
pub const tls_protocol_name = types.StringAttribute{
    .name = "tls.protocol.name",
    .brief = "Normalized lowercase protocol name parsed from original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Numeric part of the version parsed from the original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)
///
/// # Examples
///
/// - 1.2
/// - 3
/// Note: This attribute is experimental and may change in the future.
pub const tls_protocol_version = types.StringAttribute{
    .name = "tls.protocol.version",
    .brief = "Numeric part of the version parsed from the original string of the negotiated [SSL/TLS protocol version](https://docs.openssl.org/1.1.1/man3/SSL_get_version/#return-values)",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Absolute URL describing a network resource according to [RFC3986](https://www.rfc-editor.org/rfc/rfc3986)
///
/// # Examples
///
/// - https://localhost:9200/index/_search?q=user.id:kimchy
pub const url_full = types.StringAttribute{
    .name = "url.full",
    .brief = "Absolute URL describing a network resource according to [RFC3986](https://www.rfc-editor.org/rfc/rfc3986)",
    .stability = .stable,
    .requirement_level = .required,
};

/// The [URI path](https://www.rfc-editor.org/rfc/rfc3986#section-3.3) component
///
/// # Examples
///
/// - /search
pub const url_path = types.StringAttribute{
    .name = "url.path",
    .brief = "The [URI path](https://www.rfc-editor.org/rfc/rfc3986#section-3.3) component",
    .stability = .stable,
    .requirement_level = .required,
};

/// The [URI query](https://www.rfc-editor.org/rfc/rfc3986#section-3.4) component
///
/// # Examples
///
/// - q=OpenTelemetry
pub const url_query = types.StringAttribute{
    .name = "url.query",
    .brief = "The [URI query](https://www.rfc-editor.org/rfc/rfc3986#section-3.4) component",
    .stability = .stable,
    .requirement_level = .opt_in,
};

/// The [URI scheme](https://www.rfc-editor.org/rfc/rfc3986#section-3.1) component identifying the used protocol.
///
/// # Examples
///
/// - https
/// - ftp
/// - telnet
pub const url_scheme = types.StringAttribute{
    .name = "url.scheme",
    .brief = "The [URI scheme](https://www.rfc-editor.org/rfc/rfc3986#section-3.1) component identifying the used protocol.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The low-cardinality template of an [absolute path reference](https://www.rfc-editor.org/rfc/rfc3986#section-4.2).
///
/// # Examples
///
/// - /users/{id}
/// - /users/:id
/// - /users?id={id}
/// Note: This attribute is experimental and may change in the future.
pub const url_template = types.StringAttribute{
    .name = "url.template",
    .brief = "The low-cardinality template of an [absolute path reference](https://www.rfc-editor.org/rfc/rfc3986#section-4.2).",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Full user-agent string is generated by Cosmos DB SDK
///
/// # Examples
///
/// - cosmos-netstandard-sdk/3.23.0\|3.23.1\|1\|X64\|Linux 5.4.0-1098-azure 104 18\|.NET Core 3.1.32\|S\|
pub const user_agent_original = types.StringAttribute{
    .name = "user_agent.original",
    .brief = "Full user-agent string is generated by Cosmos DB SDK",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// Specifies the category of synthetic traffic, such as tests or bots.
/// Note: This attribute is experimental and may change in the future.
pub const user_agent_synthetic_type = types.StringAttribute{
    .name = "user_agent.synthetic.type",
    .brief = "Specifies the category of synthetic traffic, such as tests or bots.",
    .stability = .development,
    .requirement_level = .opt_in,
};

test "semantic trace attributes" {
    @import("std").testing.refAllDecls(@This());
}
