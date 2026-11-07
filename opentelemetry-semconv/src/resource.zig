// DO NOT EDIT, this is an auto-generated file
//
// If you want to update the file:
// - Edit the template at scripts/templates/registry/zig/resource.zig.j2
// - Run the script at scripts/generate-consts-from-spec.sh

//! # Semantic Resource Attributes
//!
//! The entire set of semantic resource attributes (or [conventions](https://opentelemetry.io/docs/concepts/semantic-conventions/)) defined by the project.

const std = @import("std");
const types = @import("types.zig");

/// Uniquely identifies the framework API revision offered by a version (`os.version`) of the android operating system. More information can be found [here](https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels).
///
/// # Examples
///
/// - 33
/// - 32
/// Note: This attribute is experimental and may change in the future.
pub const android_os_api_level = types.StringAttribute{
    .name = "android.os.api_level",
    .brief = "Uniquely identifies the framework API revision offered by a version (`os.version`) of the android operating system. More information can be found [here](https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A unique identifier representing the installation of an application on a specific device
///
/// # Examples
///
/// - 2ab2916d-a51f-4ac8-80ee-45ac31a28092
/// Note: This attribute is experimental and may change in the future.
pub const app_installation_id = types.StringAttribute{
    .name = "app.installation.id",
    .brief = "A unique identifier representing the installation of an application on a specific device",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The ARN of an [ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html).
///
/// # Examples
///
/// - arn:aws:ecs:us-west-2:123456789123:cluster/my-cluster
/// Note: This attribute is experimental and may change in the future.
pub const aws_ecs_cluster_arn = types.StringAttribute{
    .name = "aws.ecs.cluster.arn",
    .brief = "The ARN of an [ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/clusters.html).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The Amazon Resource Name (ARN) of an [ECS container instance](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_instances.html).
///
/// # Examples
///
/// - arn:aws:ecs:us-west-1:123456789123:container/32624152-9086-4f0e-acae-1a75b14fe4d9
/// Note: This attribute is experimental and may change in the future.
pub const aws_ecs_container_arn = types.StringAttribute{
    .name = "aws.ecs.container.arn",
    .brief = "The Amazon Resource Name (ARN) of an [ECS container instance](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_instances.html).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The [launch type](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html) for an ECS task.
/// Note: This attribute is experimental and may change in the future.
pub const aws_ecs_launchtype = types.StringAttribute{
    .name = "aws.ecs.launchtype",
    .brief = "The [launch type](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html) for an ECS task.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The ARN of a running [ECS task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-account-settings.html#ecs-resource-ids).
///
/// # Examples
///
/// - arn:aws:ecs:us-west-1:123456789123:task/10838bed-421f-43ef-870a-f43feacbbb5b
/// - arn:aws:ecs:us-west-1:123456789123:task/my-cluster/task-id/23ebb8ac-c18f-46c6-8bbe-d55d0e37cfbd
/// Note: This attribute is experimental and may change in the future.
pub const aws_ecs_task_arn = types.StringAttribute{
    .name = "aws.ecs.task.arn",
    .brief = "The ARN of a running [ECS task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-account-settings.html#ecs-resource-ids).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The family name of the [ECS task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) used to create the ECS task.
///
/// # Examples
///
/// - opentelemetry-family
/// Note: This attribute is experimental and may change in the future.
pub const aws_ecs_task_family = types.StringAttribute{
    .name = "aws.ecs.task.family",
    .brief = "The family name of the [ECS task definition](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) used to create the ECS task.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The ID of a running ECS task. The ID MUST be extracted from `task.arn`.
///
/// # Examples
///
/// - 10838bed-421f-43ef-870a-f43feacbbb5b
/// - 23ebb8ac-c18f-46c6-8bbe-d55d0e37cfbd
/// Note: This attribute is experimental and may change in the future.
pub const aws_ecs_task_id = types.StringAttribute{
    .name = "aws.ecs.task.id",
    .brief = "The ID of a running ECS task. The ID MUST be extracted from `task.arn`.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The revision for the task definition used to create the ECS task.
///
/// # Examples
///
/// - 8
/// - 26
/// Note: This attribute is experimental and may change in the future.
pub const aws_ecs_task_revision = types.StringAttribute{
    .name = "aws.ecs.task.revision",
    .brief = "The revision for the task definition used to create the ECS task.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The ARN of an EKS cluster.
///
/// # Examples
///
/// - arn:aws:ecs:us-west-2:123456789123:cluster/my-cluster
/// Note: This attribute is experimental and may change in the future.
pub const aws_eks_cluster_arn = types.StringAttribute{
    .name = "aws.eks.cluster.arn",
    .brief = "The ARN of an EKS cluster.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The Amazon Resource Name(s) (ARN) of the AWS log group(s).
///
/// # Examples
///
/// - [\"arn:aws:logs:us-west-1:123456789012:log-group:/aws/my/group:*\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_log_group_arns = types.StringArrayAttribute{
    .name = "aws.log.group.arns",
    .brief = "The Amazon Resource Name(s) (ARN) of the AWS log group(s).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name(s) of the AWS log group(s) an application is writing to.
///
/// # Examples
///
/// - [\"/aws/lambda/my-function\", \"opentelemetry-service\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_log_group_names = types.StringArrayAttribute{
    .name = "aws.log.group.names",
    .brief = "The name(s) of the AWS log group(s) an application is writing to.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The ARN(s) of the AWS log stream(s).
///
/// # Examples
///
/// - [\"arn:aws:logs:us-west-1:123456789012:log-group:/aws/my/group:log-stream:logs/main/10838bed-421f-43ef-870a-f43feacbbb5b\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_log_stream_arns = types.StringArrayAttribute{
    .name = "aws.log.stream.arns",
    .brief = "The ARN(s) of the AWS log stream(s).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name(s) of the AWS log stream(s) an application is writing to.
///
/// # Examples
///
/// - [\"logs/main/10838bed-421f-43ef-870a-f43feacbbb5b\"]
/// Note: This attribute is experimental and may change in the future.
pub const aws_log_stream_names = types.StringArrayAttribute{
    .name = "aws.log.stream.names",
    .brief = "The name(s) of the AWS log stream(s) an application is writing to.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Array of brand name and version separated by a space
///
/// # Examples
///
/// - [\" Not A;Brand 99\", \"Chromium 99\", \"Chrome 99\"]
/// Note: This attribute is experimental and may change in the future.
pub const browser_brands = types.StringArrayAttribute{
    .name = "browser.brands",
    .brief = "Array of brand name and version separated by a space",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Preferred language of the user using the browser
///
/// # Examples
///
/// - en
/// - en-US
/// - fr
/// - fr-FR
/// Note: This attribute is experimental and may change in the future.
pub const browser_language = types.StringAttribute{
    .name = "browser.language",
    .brief = "Preferred language of the user using the browser",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A boolean that is true if the browser is running on a mobile device
/// Note: This attribute is experimental and may change in the future.
pub const browser_mobile = types.BooleanAttribute{
    .name = "browser.mobile",
    .brief = "A boolean that is true if the browser is running on a mobile device",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The platform on which the browser is running
///
/// # Examples
///
/// - Windows
/// - macOS
/// - Android
/// Note: This attribute is experimental and may change in the future.
pub const browser_platform = types.StringAttribute{
    .name = "browser.platform",
    .brief = "The platform on which the browser is running",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The human readable name of the pipeline within a CI/CD system.
///
/// # Examples
///
/// - Build and Test
/// - Lint
/// - Deploy Go Project
/// - deploy_to_environment
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_name = types.StringAttribute{
    .name = "cicd.pipeline.name",
    .brief = "The human readable name of the pipeline within a CI/CD system.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The unique identifier of a pipeline run within a CI/CD system.
///
/// # Examples
///
/// - 120912
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_run_id = types.StringAttribute{
    .name = "cicd.pipeline.run.id",
    .brief = "The unique identifier of a pipeline run within a CI/CD system.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The [URL](https://wikipedia.org/wiki/URL) of the pipeline run, providing the complete address in order to locate and identify the pipeline run.
///
/// # Examples
///
/// - https://github.com/open-telemetry/semantic-conventions/actions/runs/9753949763?pr=1075
/// Note: This attribute is experimental and may change in the future.
pub const cicd_pipeline_run_url_full = types.StringAttribute{
    .name = "cicd.pipeline.run.url.full",
    .brief = "The [URL](https://wikipedia.org/wiki/URL) of the pipeline run, providing the complete address in order to locate and identify the pipeline run.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The unique identifier of a worker within a CICD system.
///
/// # Examples
///
/// - abc123
/// - 10.0.1.2
/// - controller
/// Note: This attribute is experimental and may change in the future.
pub const cicd_worker_id = types.StringAttribute{
    .name = "cicd.worker.id",
    .brief = "The unique identifier of a worker within a CICD system.",
    .stability = .development,
    .requirement_level = .required,
};

/// The name of a worker within a CICD system.
///
/// # Examples
///
/// - agent-abc
/// - controller
/// - Ubuntu LTS
/// Note: This attribute is experimental and may change in the future.
pub const cicd_worker_name = types.StringAttribute{
    .name = "cicd.worker.name",
    .brief = "The name of a worker within a CICD system.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The [URL](https://wikipedia.org/wiki/URL) of the worker, providing the complete address in order to locate and identify the worker.
///
/// # Examples
///
/// - https://cicd.example.org/worker/abc123
/// Note: This attribute is experimental and may change in the future.
pub const cicd_worker_url_full = types.StringAttribute{
    .name = "cicd.worker.url.full",
    .brief = "The [URL](https://wikipedia.org/wiki/URL) of the worker, providing the complete address in order to locate and identify the worker.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The cloud account ID the resource is assigned to.
///
/// # Examples
///
/// - 111111111111
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const cloud_account_id = types.StringAttribute{
    .name = "cloud.account.id",
    .brief = "The cloud account ID the resource is assigned to.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Cloud regions often have multiple, isolated locations known as zones to increase availability. Availability zone represents the zone where the resource is running.
///
/// # Examples
///
/// - us-east-1c
/// Note: This attribute is experimental and may change in the future.
pub const cloud_availability_zone = types.StringAttribute{
    .name = "cloud.availability_zone",
    .brief = "Cloud regions often have multiple, isolated locations known as zones to increase availability. Availability zone represents the zone where the resource is running.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The cloud platform in use.
/// Note: This attribute is experimental and may change in the future.
pub const cloud_platform = types.StringAttribute{
    .name = "cloud.platform",
    .brief = "The cloud platform in use.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Name of the cloud provider.
/// Note: This attribute is experimental and may change in the future.
pub const cloud_provider = types.StringAttribute{
    .name = "cloud.provider",
    .brief = "Name of the cloud provider.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The geographical region within a cloud provider. When associated with a resource, this attribute specifies the region where the resource operates. When calling services or APIs deployed on a cloud, this attribute identifies the region where the called destination is deployed.
///
/// # Examples
///
/// - us-central1
/// - us-east-1
/// Note: This attribute is experimental and may change in the future.
pub const cloud_region = types.StringAttribute{
    .name = "cloud.region",
    .brief = "The geographical region within a cloud provider. When associated with a resource, this attribute specifies the region where the resource operates. When calling services or APIs deployed on a cloud, this attribute identifies the region where the called destination is deployed.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Cloud provider-specific native identifier of the monitored cloud resource (e.g. an [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) on AWS, a [fully qualified resource ID](https://learn.microsoft.com/rest/api/resources/resources/get-by-id) on Azure, a [full resource name](https://google.aip.dev/122#full-resource-names) on GCP)
///
/// # Examples
///
/// - arn:aws:lambda:REGION:ACCOUNT_ID:function:my-function
/// - //run.googleapis.com/projects/PROJECT_ID/locations/LOCATION_ID/services/SERVICE_ID
/// - /subscriptions/<SUBSCRIPTION_GUID>/resourceGroups/<RG>/providers/Microsoft.Web/sites/<FUNCAPP>/functions/<FUNC>
/// Note: This attribute is experimental and may change in the future.
pub const cloud_resource_id = types.StringAttribute{
    .name = "cloud.resource_id",
    .brief = "Cloud provider-specific native identifier of the monitored cloud resource (e.g. an [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) on AWS, a [fully qualified resource ID](https://learn.microsoft.com/rest/api/resources/resources/get-by-id) on Azure, a [full resource name](https://google.aip.dev/122#full-resource-names) on GCP)",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The guid of the application.
///
/// # Examples
///
/// - 218fc5a9-a5f1-4b54-aa05-46717d0ab26d
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_app_id = types.StringAttribute{
    .name = "cloudfoundry.app.id",
    .brief = "The guid of the application.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the application.
///
/// # Examples
///
/// - my-app-name
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_app_name = types.StringAttribute{
    .name = "cloudfoundry.app.name",
    .brief = "The name of the application.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The guid of the CloudFoundry org the application is running in.
///
/// # Examples
///
/// - 218fc5a9-a5f1-4b54-aa05-46717d0ab26d
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_org_id = types.StringAttribute{
    .name = "cloudfoundry.org.id",
    .brief = "The guid of the CloudFoundry org the application is running in.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the CloudFoundry organization the app is running in.
///
/// # Examples
///
/// - my-org-name
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_org_name = types.StringAttribute{
    .name = "cloudfoundry.org.name",
    .brief = "The name of the CloudFoundry organization the app is running in.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID identifying the process.
///
/// # Examples
///
/// - 218fc5a9-a5f1-4b54-aa05-46717d0ab26d
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_process_id = types.StringAttribute{
    .name = "cloudfoundry.process.id",
    .brief = "The UID identifying the process.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The type of process.
///
/// # Examples
///
/// - web
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_process_type = types.StringAttribute{
    .name = "cloudfoundry.process.type",
    .brief = "The type of process.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The guid of the CloudFoundry space the application is running in.
///
/// # Examples
///
/// - 218fc5a9-a5f1-4b54-aa05-46717d0ab26d
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_space_id = types.StringAttribute{
    .name = "cloudfoundry.space.id",
    .brief = "The guid of the CloudFoundry space the application is running in.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the CloudFoundry space the application is running in.
///
/// # Examples
///
/// - my-space-name
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_space_name = types.StringAttribute{
    .name = "cloudfoundry.space.name",
    .brief = "The name of the CloudFoundry space the application is running in.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A guid or another name describing the event source.
///
/// # Examples
///
/// - cf/gorouter
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_system_id = types.StringAttribute{
    .name = "cloudfoundry.system.id",
    .brief = "A guid or another name describing the event source.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A guid describing the concrete instance of the event source.
///
/// # Examples
///
/// - 218fc5a9-a5f1-4b54-aa05-46717d0ab26d
/// Note: This attribute is experimental and may change in the future.
pub const cloudfoundry_system_instance_id = types.StringAttribute{
    .name = "cloudfoundry.system.instance.id",
    .brief = "A guid describing the concrete instance of the event source.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The command used to run the container (i.e. the command name).
///
/// # Examples
///
/// - otelcontribcol
/// Note: This attribute is experimental and may change in the future.
pub const container_command = types.StringAttribute{
    .name = "container.command",
    .brief = "The command used to run the container (i.e. the command name).",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// All the command arguments (including the command/executable itself) run by the container.
///
/// # Examples
///
/// - [\"otelcontribcol\", \"--config\", \"config.yaml\"]
/// Note: This attribute is experimental and may change in the future.
pub const container_command_args = types.StringArrayAttribute{
    .name = "container.command_args",
    .brief = "All the command arguments (including the command/executable itself) run by the container.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The full command run by the container as a single string representing the full command.
///
/// # Examples
///
/// - otelcontribcol --config config.yaml
/// Note: This attribute is experimental and may change in the future.
pub const container_command_line = types.StringAttribute{
    .name = "container.command_line",
    .brief = "The full command run by the container as a single string representing the full command.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Container ID. Usually a UUID, as for example used to [identify Docker containers](https://docs.docker.com/engine/containers/run/#container-identification). The UUID might be abbreviated.
///
/// # Examples
///
/// - a3bf90e006b2
/// Note: This attribute is experimental and may change in the future.
pub const container_id = types.StringAttribute{
    .name = "container.id",
    .brief = "Container ID. Usually a UUID, as for example used to [identify Docker containers](https://docs.docker.com/engine/containers/run/#container-identification). The UUID might be abbreviated.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Runtime specific image identifier. Usually a hash algorithm followed by a UUID.
///
/// # Examples
///
/// - sha256:19c92d0a00d1b66d897bceaa7319bee0dd38a10a851c60bcec9474aa3f01e50f
/// Note: This attribute is experimental and may change in the future.
pub const container_image_id = types.StringAttribute{
    .name = "container.image.id",
    .brief = "Runtime specific image identifier. Usually a hash algorithm followed by a UUID.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Name of the image the container was built on.
///
/// # Examples
///
/// - gcr.io/opentelemetry/operator
/// Note: This attribute is experimental and may change in the future.
pub const container_image_name = types.StringAttribute{
    .name = "container.image.name",
    .brief = "Name of the image the container was built on.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Repo digests of the container image as provided by the container runtime.
///
/// # Examples
///
/// - [\"example@sha256:afcc7f1ac1b49db317a7196c902e61c6c3c4607d63599ee1a82d702d249a0ccb\", \"internal.registry.example.com:5000/example@sha256:b69959407d21e8a062e0416bf13405bb2b71ed7a84dde4158ebafacfa06f5578\"]
/// Note: This attribute is experimental and may change in the future.
pub const container_image_repo_digests = types.StringArrayAttribute{
    .name = "container.image.repo_digests",
    .brief = "Repo digests of the container image as provided by the container runtime.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Container image tags. An example can be found in [Docker Image Inspect](https://docs.docker.com/engine/api/v1.43/#tag/Image/operation/ImageInspect). Should be only the `<tag>` section of the full name for example from `registry.example.com/my-org/my-image:<tag>`.
///
/// # Examples
///
/// - [\"v1.27.1\", \"3.5.7-0\"]
/// Note: This attribute is experimental and may change in the future.
pub const container_image_tags = types.StringArrayAttribute{
    .name = "container.image.tags",
    .brief = "Container image tags. An example can be found in [Docker Image Inspect](https://docs.docker.com/engine/api/v1.43/#tag/Image/operation/ImageInspect). Should be only the `<tag>` section of the full name for example from `registry.example.com/my-org/my-image:<tag>`.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Container labels, `<key>` being the label name, the value being the label value.
///
/// # Examples
///
/// - nginx
/// Note: This attribute is experimental and may change in the future.
pub const container_label = types.StringAttribute{
    .name = "container.label",
    .brief = "Container labels, `<key>` being the label name, the value being the label value.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Container name used by container runtime.
///
/// # Examples
///
/// - opentelemetry-autoconf
/// Note: This attribute is experimental and may change in the future.
pub const container_name = types.StringAttribute{
    .name = "container.name",
    .brief = "Container name used by container runtime.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The container runtime managing this container.
///
/// # Examples
///
/// - docker
/// - containerd
/// - rkt
/// Note: This attribute is experimental and may change in the future.
pub const container_runtime = types.StringAttribute{
    .name = "container.runtime",
    .brief = "The container runtime managing this container.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Name of the [deployment environment](https://wikipedia.org/wiki/Deployment_environment) (aka deployment tier).
///
/// # Examples
///
/// - staging
/// - production
/// Note: This attribute is experimental and may change in the future.
pub const deployment_environment_name = types.StringAttribute{
    .name = "deployment.environment.name",
    .brief = "Name of the [deployment environment](https://wikipedia.org/wiki/Deployment_environment) (aka deployment tier).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A unique identifier representing the device
///
/// # Examples
///
/// - 123456789012345
/// - 01:23:45:67:89:AB
/// Note: This attribute is experimental and may change in the future.
pub const device_id = types.StringAttribute{
    .name = "device.id",
    .brief = "A unique identifier representing the device",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the device manufacturer
///
/// # Examples
///
/// - Apple
/// - Samsung
/// Note: This attribute is experimental and may change in the future.
pub const device_manufacturer = types.StringAttribute{
    .name = "device.manufacturer",
    .brief = "The name of the device manufacturer",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The model identifier for the device
///
/// # Examples
///
/// - iPhone3,4
/// - SM-G920F
/// Note: This attribute is experimental and may change in the future.
pub const device_model_identifier = types.StringAttribute{
    .name = "device.model.identifier",
    .brief = "The model identifier for the device",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The marketing name for the device model
///
/// # Examples
///
/// - iPhone 6s Plus
/// - Samsung Galaxy S6
/// Note: This attribute is experimental and may change in the future.
pub const device_model_name = types.StringAttribute{
    .name = "device.model.name",
    .brief = "The marketing name for the device model",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The execution environment ID as a string, that will be potentially reused for other invocations to the same function/function version.
///
/// # Examples
///
/// - 2021/06/28/[$LATEST]2f399eb14537447da05ab2a2e39309de
/// Note: This attribute is experimental and may change in the future.
pub const faas_instance = types.StringAttribute{
    .name = "faas.instance",
    .brief = "The execution environment ID as a string, that will be potentially reused for other invocations to the same function/function version.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The amount of memory available to the serverless function converted to Bytes.
///
/// # Examples
///
/// - 134217728
/// Note: This attribute is experimental and may change in the future.
pub const faas_max_memory = types.IntAttribute{
    .name = "faas.max_memory",
    .brief = "The amount of memory available to the serverless function converted to Bytes.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the single function that this runtime instance executes.
///
/// # Examples
///
/// - my-function
/// - myazurefunctionapp/some-function-name
/// Note: This attribute is experimental and may change in the future.
pub const faas_name = types.StringAttribute{
    .name = "faas.name",
    .brief = "The name of the single function that this runtime instance executes.",
    .stability = .development,
    .requirement_level = .required,
};

/// The immutable version of the function being executed.
///
/// # Examples
///
/// - 26
/// - pinkfroid-00002
/// Note: This attribute is experimental and may change in the future.
pub const faas_version = types.StringAttribute{
    .name = "faas.version",
    .brief = "The immutable version of the function being executed.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The container within GCP where the AppHub application is defined.
///
/// # Examples
///
/// - projects/my-container-project
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_application_container = types.StringAttribute{
    .name = "gcp.apphub.application.container",
    .brief = "The container within GCP where the AppHub application is defined.",
    .stability = .development,
    .requirement_level = .required,
};

/// The name of the application as configured in AppHub.
///
/// # Examples
///
/// - my-application
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_application_id = types.StringAttribute{
    .name = "gcp.apphub.application.id",
    .brief = "The name of the application as configured in AppHub.",
    .stability = .development,
    .requirement_level = .required,
};

/// The GCP zone or region where the application is defined.
///
/// # Examples
///
/// - us-central1
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_application_location = types.StringAttribute{
    .name = "gcp.apphub.application.location",
    .brief = "The GCP zone or region where the application is defined.",
    .stability = .development,
    .requirement_level = .required,
};

/// Criticality of a service indicates its importance to the business.
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_service_criticality_type = types.StringAttribute{
    .name = "gcp.apphub.service.criticality_type",
    .brief = "Criticality of a service indicates its importance to the business.",
    .stability = .development,
    .requirement_level = .required,
};

/// Environment of a service is the stage of a software lifecycle.
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_service_environment_type = types.StringAttribute{
    .name = "gcp.apphub.service.environment_type",
    .brief = "Environment of a service is the stage of a software lifecycle.",
    .stability = .development,
    .requirement_level = .required,
};

/// The name of the service as configured in AppHub.
///
/// # Examples
///
/// - my-service
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_service_id = types.StringAttribute{
    .name = "gcp.apphub.service.id",
    .brief = "The name of the service as configured in AppHub.",
    .stability = .development,
    .requirement_level = .required,
};

/// Criticality of a workload indicates its importance to the business.
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_workload_criticality_type = types.StringAttribute{
    .name = "gcp.apphub.workload.criticality_type",
    .brief = "Criticality of a workload indicates its importance to the business.",
    .stability = .development,
    .requirement_level = .required,
};

/// Environment of a workload is the stage of a software lifecycle.
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_workload_environment_type = types.StringAttribute{
    .name = "gcp.apphub.workload.environment_type",
    .brief = "Environment of a workload is the stage of a software lifecycle.",
    .stability = .development,
    .requirement_level = .required,
};

/// The name of the workload as configured in AppHub.
///
/// # Examples
///
/// - my-workload
/// Note: This attribute is experimental and may change in the future.
pub const gcp_apphub_workload_id = types.StringAttribute{
    .name = "gcp.apphub.workload.id",
    .brief = "The name of the workload as configured in AppHub.",
    .stability = .development,
    .requirement_level = .required,
};

/// The name of the Cloud Run [execution](https://cloud.google.com/run/docs/managing/job-executions) being run for the Job, as set by the [`CLOUD_RUN_EXECUTION`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.
///
/// # Examples
///
/// - job-name-xxxx
/// - sample-job-mdw84
/// Note: This attribute is experimental and may change in the future.
pub const gcp_cloud_run_job_execution = types.StringAttribute{
    .name = "gcp.cloud_run.job.execution",
    .brief = "The name of the Cloud Run [execution](https://cloud.google.com/run/docs/managing/job-executions) being run for the Job, as set by the [`CLOUD_RUN_EXECUTION`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The index for a task within an execution as provided by the [`CLOUD_RUN_TASK_INDEX`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.
///
/// # Examples
///
/// - 0
/// - 1
/// Note: This attribute is experimental and may change in the future.
pub const gcp_cloud_run_job_task_index = types.IntAttribute{
    .name = "gcp.cloud_run.job.task_index",
    .brief = "The index for a task within an execution as provided by the [`CLOUD_RUN_TASK_INDEX`](https://cloud.google.com/run/docs/container-contract#jobs-env-vars) environment variable.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The hostname of a GCE instance. This is the full value of the default or [custom hostname](https://cloud.google.com/compute/docs/instances/custom-hostname-vm).
///
/// # Examples
///
/// - my-host1234.example.com
/// - sample-vm.us-west1-b.c.my-project.internal
/// Note: This attribute is experimental and may change in the future.
pub const gcp_gce_instance_hostname = types.StringAttribute{
    .name = "gcp.gce.instance.hostname",
    .brief = "The hostname of a GCE instance. This is the full value of the default or [custom hostname](https://cloud.google.com/compute/docs/instances/custom-hostname-vm).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The instance name of a GCE instance. This is the value provided by `host.name`, the visible name of the instance in the Cloud Console UI, and the prefix for the default hostname of the instance as defined by the [default internal DNS name](https://cloud.google.com/compute/docs/internal-dns#instance-fully-qualified-domain-names).
///
/// # Examples
///
/// - instance-1
/// - my-vm-name
/// Note: This attribute is experimental and may change in the future.
pub const gcp_gce_instance_name = types.StringAttribute{
    .name = "gcp.gce.instance.name",
    .brief = "The instance name of a GCE instance. This is the value provided by `host.name`, the visible name of the instance in the Cloud Console UI, and the prefix for the default hostname of the instance as defined by the [default internal DNS name](https://cloud.google.com/compute/docs/internal-dns#instance-fully-qualified-domain-names).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Unique identifier for the application
///
/// # Examples
///
/// - 2daa2797-e42b-4624-9322-ec3f968df4da
/// Note: This attribute is experimental and may change in the future.
pub const heroku_app_id = types.StringAttribute{
    .name = "heroku.app.id",
    .brief = "Unique identifier for the application",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Commit hash for the current release
///
/// # Examples
///
/// - e6134959463efd8966b20e75b913cafe3f5ec
/// Note: This attribute is experimental and may change in the future.
pub const heroku_release_commit = types.StringAttribute{
    .name = "heroku.release.commit",
    .brief = "Commit hash for the current release",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Time and date the release was created
///
/// # Examples
///
/// - 2022-10-23T18:00:42Z
/// Note: This attribute is experimental and may change in the future.
pub const heroku_release_creation_timestamp = types.StringAttribute{
    .name = "heroku.release.creation_timestamp",
    .brief = "Time and date the release was created",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The CPU architecture the host system is running on.
/// Note: This attribute is experimental and may change in the future.
pub const host_arch = types.StringAttribute{
    .name = "host.arch",
    .brief = "The CPU architecture the host system is running on.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The amount of level 2 memory cache available to the processor (in Bytes).
///
/// # Examples
///
/// - 12288000
/// Note: This attribute is experimental and may change in the future.
pub const host_cpu_cache_l2_size = types.IntAttribute{
    .name = "host.cpu.cache.l2.size",
    .brief = "The amount of level 2 memory cache available to the processor (in Bytes).",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Family or generation of the CPU.
///
/// # Examples
///
/// - 6
/// - PA-RISC 1.1e
/// Note: This attribute is experimental and may change in the future.
pub const host_cpu_family = types.StringAttribute{
    .name = "host.cpu.family",
    .brief = "Family or generation of the CPU.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Model identifier. It provides more granular information about the CPU, distinguishing it from other CPUs within the same family.
///
/// # Examples
///
/// - 6
/// - 9000/778/B180L
/// Note: This attribute is experimental and may change in the future.
pub const host_cpu_model_id = types.StringAttribute{
    .name = "host.cpu.model.id",
    .brief = "Model identifier. It provides more granular information about the CPU, distinguishing it from other CPUs within the same family.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Model designation of the processor.
///
/// # Examples
///
/// - 11th Gen Intel(R) Core(TM) i7-1185G7 @ 3.00GHz
/// Note: This attribute is experimental and may change in the future.
pub const host_cpu_model_name = types.StringAttribute{
    .name = "host.cpu.model.name",
    .brief = "Model designation of the processor.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Stepping or core revisions.
///
/// # Examples
///
/// - 1
/// - r1p1
/// Note: This attribute is experimental and may change in the future.
pub const host_cpu_stepping = types.StringAttribute{
    .name = "host.cpu.stepping",
    .brief = "Stepping or core revisions.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Processor manufacturer identifier. A maximum 12-character string.
///
/// # Examples
///
/// - GenuineIntel
/// Note: This attribute is experimental and may change in the future.
pub const host_cpu_vendor_id = types.StringAttribute{
    .name = "host.cpu.vendor.id",
    .brief = "Processor manufacturer identifier. A maximum 12-character string.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Unique host ID. For Cloud, this must be the instance_id assigned by the cloud provider. For non-containerized systems, this should be the `machine-id`. See the table below for the sources to use to determine the `machine-id` based on operating system.
///
/// # Examples
///
/// - fdbf79e8af94cb7f9e8df36789187052
/// Note: This attribute is experimental and may change in the future.
pub const host_id = types.StringAttribute{
    .name = "host.id",
    .brief = "Unique host ID. For Cloud, this must be the instance_id assigned by the cloud provider. For non-containerized systems, this should be the `machine-id`. See the table below for the sources to use to determine the `machine-id` based on operating system.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// VM image ID or host OS image ID. For Cloud, this value is from the provider.
///
/// # Examples
///
/// - ami-07b06b442921831e5
/// Note: This attribute is experimental and may change in the future.
pub const host_image_id = types.StringAttribute{
    .name = "host.image.id",
    .brief = "VM image ID or host OS image ID. For Cloud, this value is from the provider.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Name of the VM image or OS install the host was instantiated from.
///
/// # Examples
///
/// - infra-ami-eks-worker-node-7d4ec78312
/// - CentOS-8-x86_64-1905
/// Note: This attribute is experimental and may change in the future.
pub const host_image_name = types.StringAttribute{
    .name = "host.image.name",
    .brief = "Name of the VM image or OS install the host was instantiated from.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The version string of the VM image or host OS as defined in [Version Attributes](/docs/resource/README.md#version-attributes).
///
/// # Examples
///
/// - 0.1
/// Note: This attribute is experimental and may change in the future.
pub const host_image_version = types.StringAttribute{
    .name = "host.image.version",
    .brief = "The version string of the VM image or host OS as defined in [Version Attributes](/docs/resource/README.md#version-attributes).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Available IP addresses of the host, excluding loopback interfaces.
///
/// # Examples
///
/// - [\"192.168.1.140\", \"fe80::abc2:4a28:737a:609e\"]
/// Note: This attribute is experimental and may change in the future.
pub const host_ip = types.StringArrayAttribute{
    .name = "host.ip",
    .brief = "Available IP addresses of the host, excluding loopback interfaces.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Available MAC addresses of the host, excluding loopback interfaces.
///
/// # Examples
///
/// - [\"AC-DE-48-23-45-67\", \"AC-DE-48-23-45-67-01-9F\"]
/// Note: This attribute is experimental and may change in the future.
pub const host_mac = types.StringArrayAttribute{
    .name = "host.mac",
    .brief = "Available MAC addresses of the host, excluding loopback interfaces.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// Name of the host. On Unix systems, it may contain what the hostname command returns, or the fully qualified hostname, or another name specified by the user.
///
/// # Examples
///
/// - opentelemetry-test
/// Note: This attribute is experimental and may change in the future.
pub const host_name = types.StringAttribute{
    .name = "host.name",
    .brief = "Name of the host. On Unix systems, it may contain what the hostname command returns, or the fully qualified hostname, or another name specified by the user.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Type of host. For Cloud, this must be the machine type.
///
/// # Examples
///
/// - n1-standard-1
/// Note: This attribute is experimental and may change in the future.
pub const host_type = types.StringAttribute{
    .name = "host.type",
    .brief = "Type of host. For Cloud, this must be the machine type.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the cluster.
///
/// # Examples
///
/// - opentelemetry-cluster
/// Note: This attribute is experimental and may change in the future.
pub const k8s_cluster_name = types.StringAttribute{
    .name = "k8s.cluster.name",
    .brief = "The name of the cluster.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// A pseudo-ID for the cluster, set to the UID of the `kube-system` namespace.
///
/// # Examples
///
/// - 218fc5a9-a5f1-4b54-aa05-46717d0ab26d
/// Note: This attribute is experimental and may change in the future.
pub const k8s_cluster_uid = types.StringAttribute{
    .name = "k8s.cluster.uid",
    .brief = "A pseudo-ID for the cluster, set to the UID of the `kube-system` namespace.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the Container from Pod specification, must be unique within a Pod. Container runtime usually uses different globally unique name (`container.name`).
///
/// # Examples
///
/// - redis
/// Note: This attribute is experimental and may change in the future.
pub const k8s_container_name = types.StringAttribute{
    .name = "k8s.container.name",
    .brief = "The name of the Container from Pod specification, must be unique within a Pod. Container runtime usually uses different globally unique name (`container.name`).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Number of times the container was restarted. This attribute can be used to identify a particular container (running or stopped) within a container spec.
/// Note: This attribute is experimental and may change in the future.
pub const k8s_container_restart_count = types.IntAttribute{
    .name = "k8s.container.restart_count",
    .brief = "Number of times the container was restarted. This attribute can be used to identify a particular container (running or stopped) within a container spec.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Last terminated reason of the Container.
///
/// # Examples
///
/// - Evicted
/// - Error
/// Note: This attribute is experimental and may change in the future.
pub const k8s_container_status_last_terminated_reason = types.StringAttribute{
    .name = "k8s.container.status.last_terminated_reason",
    .brief = "Last terminated reason of the Container.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The cronjob annotation placed on the CronJob, the `<key>` being the annotation name, the value being the annotation value.
///
/// # Examples
///
/// - 4
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_cronjob_annotation = types.StringAttribute{
    .name = "k8s.cronjob.annotation",
    .brief = "The cronjob annotation placed on the CronJob, the `<key>` being the annotation name, the value being the annotation value.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the CronJob, the `<key>` being the label name, the value being the label value.
///
/// # Examples
///
/// - weekly
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_cronjob_label = types.StringAttribute{
    .name = "k8s.cronjob.label",
    .brief = "The label placed on the CronJob, the `<key>` being the label name, the value being the label value.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the CronJob.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_cronjob_name = types.StringAttribute{
    .name = "k8s.cronjob.name",
    .brief = "The name of the CronJob.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the CronJob.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_cronjob_uid = types.StringAttribute{
    .name = "k8s.cronjob.uid",
    .brief = "The UID of the CronJob.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the DaemonSet, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.
///
/// # Examples
///
/// - 1
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_daemonset_annotation = types.StringAttribute{
    .name = "k8s.daemonset.annotation",
    .brief = "The annotation placed on the DaemonSet, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the DaemonSet, the `<key>` being the label name, the value being the label value, even if the value is empty.
///
/// # Examples
///
/// - guestbook
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_daemonset_label = types.StringAttribute{
    .name = "k8s.daemonset.label",
    .brief = "The label placed on the DaemonSet, the `<key>` being the label name, the value being the label value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the DaemonSet.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_daemonset_name = types.StringAttribute{
    .name = "k8s.daemonset.name",
    .brief = "The name of the DaemonSet.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the DaemonSet.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_daemonset_uid = types.StringAttribute{
    .name = "k8s.daemonset.uid",
    .brief = "The UID of the DaemonSet.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the Deployment, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.
///
/// # Examples
///
/// - 1
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_deployment_annotation = types.StringAttribute{
    .name = "k8s.deployment.annotation",
    .brief = "The annotation placed on the Deployment, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the Deployment, the `<key>` being the label name, the value being the label value, even if the value is empty.
///
/// # Examples
///
/// - guestbook
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_deployment_label = types.StringAttribute{
    .name = "k8s.deployment.label",
    .brief = "The label placed on the Deployment, the `<key>` being the label name, the value being the label value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the Deployment.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_deployment_name = types.StringAttribute{
    .name = "k8s.deployment.name",
    .brief = "The name of the Deployment.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the Deployment.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_deployment_uid = types.StringAttribute{
    .name = "k8s.deployment.uid",
    .brief = "The UID of the Deployment.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the horizontal pod autoscaler.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_hpa_name = types.StringAttribute{
    .name = "k8s.hpa.name",
    .brief = "The name of the horizontal pod autoscaler.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The API version of the target resource to scale for the HorizontalPodAutoscaler.
///
/// # Examples
///
/// - apps/v1
/// - autoscaling/v2
/// Note: This attribute is experimental and may change in the future.
pub const k8s_hpa_scaletargetref_api_version = types.StringAttribute{
    .name = "k8s.hpa.scaletargetref.api_version",
    .brief = "The API version of the target resource to scale for the HorizontalPodAutoscaler.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The kind of the target resource to scale for the HorizontalPodAutoscaler.
///
/// # Examples
///
/// - Deployment
/// - StatefulSet
/// Note: This attribute is experimental and may change in the future.
pub const k8s_hpa_scaletargetref_kind = types.StringAttribute{
    .name = "k8s.hpa.scaletargetref.kind",
    .brief = "The kind of the target resource to scale for the HorizontalPodAutoscaler.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the target resource to scale for the HorizontalPodAutoscaler.
///
/// # Examples
///
/// - my-deployment
/// - my-statefulset
/// Note: This attribute is experimental and may change in the future.
pub const k8s_hpa_scaletargetref_name = types.StringAttribute{
    .name = "k8s.hpa.scaletargetref.name",
    .brief = "The name of the target resource to scale for the HorizontalPodAutoscaler.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the horizontal pod autoscaler.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_hpa_uid = types.StringAttribute{
    .name = "k8s.hpa.uid",
    .brief = "The UID of the horizontal pod autoscaler.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the Job, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.
///
/// # Examples
///
/// - 1
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_job_annotation = types.StringAttribute{
    .name = "k8s.job.annotation",
    .brief = "The annotation placed on the Job, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the Job, the `<key>` being the label name, the value being the label value, even if the value is empty.
///
/// # Examples
///
/// - ci
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_job_label = types.StringAttribute{
    .name = "k8s.job.label",
    .brief = "The label placed on the Job, the `<key>` being the label name, the value being the label value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the Job.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_job_name = types.StringAttribute{
    .name = "k8s.job.name",
    .brief = "The name of the Job.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the Job.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_job_uid = types.StringAttribute{
    .name = "k8s.job.uid",
    .brief = "The UID of the Job.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the Namespace, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.
///
/// # Examples
///
/// - 0
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_namespace_annotation = types.StringAttribute{
    .name = "k8s.namespace.annotation",
    .brief = "The annotation placed on the Namespace, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the Namespace, the `<key>` being the label name, the value being the label value, even if the value is empty.
///
/// # Examples
///
/// - default
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_namespace_label = types.StringAttribute{
    .name = "k8s.namespace.label",
    .brief = "The label placed on the Namespace, the `<key>` being the label name, the value being the label value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the namespace that the pod is running in.
///
/// # Examples
///
/// - default
/// Note: This attribute is experimental and may change in the future.
pub const k8s_namespace_name = types.StringAttribute{
    .name = "k8s.namespace.name",
    .brief = "The name of the namespace that the pod is running in.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the Node, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.
///
/// # Examples
///
/// - 0
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_node_annotation = types.StringAttribute{
    .name = "k8s.node.annotation",
    .brief = "The annotation placed on the Node, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the Node, the `<key>` being the label name, the value being the label value, even if the value is empty.
///
/// # Examples
///
/// - arm64
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_node_label = types.StringAttribute{
    .name = "k8s.node.label",
    .brief = "The label placed on the Node, the `<key>` being the label name, the value being the label value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the Node.
///
/// # Examples
///
/// - node-1
/// Note: This attribute is experimental and may change in the future.
pub const k8s_node_name = types.StringAttribute{
    .name = "k8s.node.name",
    .brief = "The name of the Node.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the Node.
///
/// # Examples
///
/// - 1eb3a0c6-0477-4080-a9cb-0cb7db65c6a2
/// Note: This attribute is experimental and may change in the future.
pub const k8s_node_uid = types.StringAttribute{
    .name = "k8s.node.uid",
    .brief = "The UID of the Node.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the Pod, the `<key>` being the annotation name, the value being the annotation value.
///
/// # Examples
///
/// - true
/// - x64
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_pod_annotation = types.StringAttribute{
    .name = "k8s.pod.annotation",
    .brief = "The annotation placed on the Pod, the `<key>` being the annotation name, the value being the annotation value.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the Pod, the `<key>` being the label name, the value being the label value.
///
/// # Examples
///
/// - my-app
/// - x64
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_pod_label = types.StringAttribute{
    .name = "k8s.pod.label",
    .brief = "The label placed on the Pod, the `<key>` being the label name, the value being the label value.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the Pod.
///
/// # Examples
///
/// - opentelemetry-pod-autoconf
/// Note: This attribute is experimental and may change in the future.
pub const k8s_pod_name = types.StringAttribute{
    .name = "k8s.pod.name",
    .brief = "The name of the Pod.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the Pod.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_pod_uid = types.StringAttribute{
    .name = "k8s.pod.uid",
    .brief = "The UID of the Pod.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the ReplicaSet, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.
///
/// # Examples
///
/// - 0
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_replicaset_annotation = types.StringAttribute{
    .name = "k8s.replicaset.annotation",
    .brief = "The annotation placed on the ReplicaSet, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the ReplicaSet, the `<key>` being the label name, the value being the label value, even if the value is empty.
///
/// # Examples
///
/// - guestbook
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_replicaset_label = types.StringAttribute{
    .name = "k8s.replicaset.label",
    .brief = "The label placed on the ReplicaSet, the `<key>` being the label name, the value being the label value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the ReplicaSet.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_replicaset_name = types.StringAttribute{
    .name = "k8s.replicaset.name",
    .brief = "The name of the ReplicaSet.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the ReplicaSet.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_replicaset_uid = types.StringAttribute{
    .name = "k8s.replicaset.uid",
    .brief = "The UID of the ReplicaSet.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the replication controller.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_replicationcontroller_name = types.StringAttribute{
    .name = "k8s.replicationcontroller.name",
    .brief = "The name of the replication controller.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the replication controller.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_replicationcontroller_uid = types.StringAttribute{
    .name = "k8s.replicationcontroller.uid",
    .brief = "The UID of the replication controller.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the resource quota.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_resourcequota_name = types.StringAttribute{
    .name = "k8s.resourcequota.name",
    .brief = "The name of the resource quota.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the resource quota.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_resourcequota_uid = types.StringAttribute{
    .name = "k8s.resourcequota.uid",
    .brief = "The UID of the resource quota.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The annotation placed on the StatefulSet, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.
///
/// # Examples
///
/// - 1
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_statefulset_annotation = types.StringAttribute{
    .name = "k8s.statefulset.annotation",
    .brief = "The annotation placed on the StatefulSet, the `<key>` being the annotation name, the value being the annotation value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The label placed on the StatefulSet, the `<key>` being the label name, the value being the label value, even if the value is empty.
///
/// # Examples
///
/// - guestbook
/// -
/// Note: This attribute is experimental and may change in the future.
pub const k8s_statefulset_label = types.StringAttribute{
    .name = "k8s.statefulset.label",
    .brief = "The label placed on the StatefulSet, the `<key>` being the label name, the value being the label value, even if the value is empty.",
    .stability = .development,
    .requirement_level = .opt_in,
};

/// The name of the StatefulSet.
///
/// # Examples
///
/// - opentelemetry
/// Note: This attribute is experimental and may change in the future.
pub const k8s_statefulset_name = types.StringAttribute{
    .name = "k8s.statefulset.name",
    .brief = "The name of the StatefulSet.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The UID of the StatefulSet.
///
/// # Examples
///
/// - 275ecb36-5aa8-4c2a-9c47-d8bb681b9aff
/// Note: This attribute is experimental and may change in the future.
pub const k8s_statefulset_uid = types.StringAttribute{
    .name = "k8s.statefulset.uid",
    .brief = "The UID of the StatefulSet.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Name of the logical partition that hosts a systems with a mainframe operating system.
///
/// # Examples
///
/// - LPAR01
/// Note: This attribute is experimental and may change in the future.
pub const mainframe_lpar_name = types.StringAttribute{
    .name = "mainframe.lpar.name",
    .brief = "Name of the logical partition that hosts a systems with a mainframe operating system.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The digest of the OCI image manifest. For container images specifically is the digest by which the container image is known.
///
/// # Examples
///
/// - sha256:e4ca62c0d62f3e886e684806dfe9d4e0cda60d54986898173c1083856cfda0f4
/// Note: This attribute is experimental and may change in the future.
pub const oci_manifest_digest = types.StringAttribute{
    .name = "oci.manifest.digest",
    .brief = "The digest of the OCI image manifest. For container images specifically is the digest by which the container image is known.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Unique identifier for a particular build or compilation of the operating system.
///
/// # Examples
///
/// - TQ3C.230805.001.B2
/// - 20E247
/// - 22621
/// Note: This attribute is experimental and may change in the future.
pub const os_build_id = types.StringAttribute{
    .name = "os.build_id",
    .brief = "Unique identifier for a particular build or compilation of the operating system.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Human readable (not intended to be parsed) OS version information, like e.g. reported by `ver` or `lsb_release -a` commands.
///
/// # Examples
///
/// - Microsoft Windows [Version 10.0.18363.778]
/// - Ubuntu 18.04.1 LTS
/// Note: This attribute is experimental and may change in the future.
pub const os_description = types.StringAttribute{
    .name = "os.description",
    .brief = "Human readable (not intended to be parsed) OS version information, like e.g. reported by `ver` or `lsb_release -a` commands.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Human readable operating system name.
///
/// # Examples
///
/// - iOS
/// - Android
/// - Ubuntu
/// Note: This attribute is experimental and may change in the future.
pub const os_name = types.StringAttribute{
    .name = "os.name",
    .brief = "Human readable operating system name.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The operating system type.
/// Note: This attribute is experimental and may change in the future.
pub const os_type = types.StringAttribute{
    .name = "os.type",
    .brief = "The operating system type.",
    .stability = .development,
    .requirement_level = .required,
};

/// The version string of the operating system as defined in [Version Attributes](/docs/resource/README.md#version-attributes).
///
/// # Examples
///
/// - 14.2.1
/// - 18.04.1
/// Note: This attribute is experimental and may change in the future.
pub const os_version = types.StringAttribute{
    .name = "os.version",
    .brief = "The version string of the operating system as defined in [Version Attributes](/docs/resource/README.md#version-attributes).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the instrumentation scope - (`InstrumentationScope.Name` in OTLP).
///
/// # Examples
///
/// - io.opentelemetry.contrib.mongodb
pub const otel_scope_name = types.StringAttribute{
    .name = "otel.scope.name",
    .brief = "The name of the instrumentation scope - (`InstrumentationScope.Name` in OTLP).",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The version of the instrumentation scope - (`InstrumentationScope.Version` in OTLP).
///
/// # Examples
///
/// - 1.0.0
pub const otel_scope_version = types.StringAttribute{
    .name = "otel.scope.version",
    .brief = "The version of the instrumentation scope - (`InstrumentationScope.Version` in OTLP).",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The command used to launch the process (i.e. the command name). On Linux based systems, can be set to the zeroth string in `proc/[pid]/cmdline`. On Windows, can be set to the first parameter extracted from `GetCommandLineW`.
///
/// # Examples
///
/// - cmd/otelcol
/// Note: This attribute is experimental and may change in the future.
pub const process_command = types.StringAttribute{
    .name = "process.command",
    .brief = "The command used to launch the process (i.e. the command name). On Linux based systems, can be set to the zeroth string in `proc/[pid]/cmdline`. On Windows, can be set to the first parameter extracted from `GetCommandLineW`.",
    .stability = .development,
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
    .requirement_level = .opt_in,
};

/// The full command used to launch the process as a single string representing the full command. On Windows, can be set to the result of `GetCommandLineW`. Do not set this if you have to assemble it just for monitoring; use `process.command_args` instead. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.
///
/// # Examples
///
/// - C:\cmd\otecol --config=\"my directory\config.yaml\"
/// Note: This attribute is experimental and may change in the future.
pub const process_command_line = types.StringAttribute{
    .name = "process.command_line",
    .brief = "The full command used to launch the process as a single string representing the full command. On Windows, can be set to the result of `GetCommandLineW`. Do not set this if you have to assemble it just for monitoring; use `process.command_args` instead. SHOULD NOT be collected by default unless there is sanitization that excludes sensitive data.",
    .stability = .development,
    .requirement_level = .opt_in,
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
    .requirement_level = .opt_in,
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
    .requirement_level = .opt_in,
};

/// The control group associated with the process.
///
/// # Examples
///
/// - 1:name=systemd:/user.slice/user-1000.slice/session-3.scope
/// - 0::/user.slice/user-1000.slice/user@1000.service/tmux-spawn-0267755b-4639-4a27-90ed-f19f88e53748.scope
/// Note: This attribute is experimental and may change in the future.
pub const process_linux_cgroup = types.StringAttribute{
    .name = "process.linux.cgroup",
    .brief = "The control group associated with the process.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The username of the user that owns the process.
///
/// # Examples
///
/// - root
/// Note: This attribute is experimental and may change in the future.
pub const process_owner = types.StringAttribute{
    .name = "process.owner",
    .brief = "The username of the user that owns the process.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Parent Process identifier (PPID).
///
/// # Examples
///
/// - 111
/// Note: This attribute is experimental and may change in the future.
pub const process_parent_pid = types.IntAttribute{
    .name = "process.parent_pid",
    .brief = "Parent Process identifier (PPID).",
    .stability = .development,
    .requirement_level = .recommended,
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
    .requirement_level = .recommended,
};

/// An additional description about the runtime of the process, for example a specific vendor customization of the runtime environment.
///
/// # Examples
///
/// - Eclipse OpenJ9 Eclipse OpenJ9 VM openj9-0.21.0
/// Note: This attribute is experimental and may change in the future.
pub const process_runtime_description = types.StringAttribute{
    .name = "process.runtime.description",
    .brief = "An additional description about the runtime of the process, for example a specific vendor customization of the runtime environment.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the runtime of this process.
///
/// # Examples
///
/// - OpenJDK Runtime Environment
/// Note: This attribute is experimental and may change in the future.
pub const process_runtime_name = types.StringAttribute{
    .name = "process.runtime.name",
    .brief = "The name of the runtime of this process.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The version of the runtime of this process, as returned by the runtime without modification.
///
/// # Examples
///
/// - 14.0.2
/// Note: This attribute is experimental and may change in the future.
pub const process_runtime_version = types.StringAttribute{
    .name = "process.runtime.version",
    .brief = "The version of the runtime of this process, as returned by the runtime without modification.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The string ID of the service instance.
///
/// # Examples
///
/// - 627cc493-f310-47de-96bd-71410b7dec09
/// Note: This attribute is experimental and may change in the future.
pub const service_instance_id = types.StringAttribute{
    .name = "service.instance.id",
    .brief = "The string ID of the service instance.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Logical name of the service.
///
/// # Examples
///
/// - shoppingcart
pub const service_name = types.StringAttribute{
    .name = "service.name",
    .brief = "Logical name of the service.",
    .stability = .stable,
    .requirement_level = .required,
};

/// A namespace for `service.name`.
///
/// # Examples
///
/// - Shop
/// Note: This attribute is experimental and may change in the future.
pub const service_namespace = types.StringAttribute{
    .name = "service.namespace",
    .brief = "A namespace for `service.name`.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The version string of the service API or implementation. The format is not defined by these conventions.
///
/// # Examples
///
/// - 2.0.0
/// - a01dbef8a
pub const service_version = types.StringAttribute{
    .name = "service.version",
    .brief = "The version string of the service API or implementation. The format is not defined by these conventions.",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The name of the auto instrumentation agent or distribution, if used.
///
/// # Examples
///
/// - parts-unlimited-java
/// Note: This attribute is experimental and may change in the future.
pub const telemetry_distro_name = types.StringAttribute{
    .name = "telemetry.distro.name",
    .brief = "The name of the auto instrumentation agent or distribution, if used.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The version string of the auto instrumentation agent or distribution, if used.
///
/// # Examples
///
/// - 1.2.3
/// Note: This attribute is experimental and may change in the future.
pub const telemetry_distro_version = types.StringAttribute{
    .name = "telemetry.distro.version",
    .brief = "The version string of the auto instrumentation agent or distribution, if used.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The language of the telemetry SDK.
pub const telemetry_sdk_language = types.StringAttribute{
    .name = "telemetry.sdk.language",
    .brief = "The language of the telemetry SDK.",
    .stability = .stable,
    .requirement_level = .required,
};

/// The name of the telemetry SDK as defined above.
///
/// # Examples
///
/// - opentelemetry
pub const telemetry_sdk_name = types.StringAttribute{
    .name = "telemetry.sdk.name",
    .brief = "The name of the telemetry SDK as defined above.",
    .stability = .stable,
    .requirement_level = .required,
};

/// The version string of the telemetry SDK.
///
/// # Examples
///
/// - 1.2.3
pub const telemetry_sdk_version = types.StringAttribute{
    .name = "telemetry.sdk.version",
    .brief = "The version string of the telemetry SDK.",
    .stability = .stable,
    .requirement_level = .required,
};

/// Full user-agent string provided by the browser
///
/// # Examples
///
/// - Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.54 Safari/537.36
pub const user_agent_original = types.StringAttribute{
    .name = "user_agent.original",
    .brief = "Full user-agent string provided by the browser",
    .stability = .stable,
    .requirement_level = .recommended,
};

/// The name of the [reference](https://git-scm.com/docs/gitglossary#def_ref) such as **branch** or **tag** in the repository.
///
/// # Examples
///
/// - my-feature-branch
/// - tag-1-test
/// Note: This attribute is experimental and may change in the future.
pub const vcs_ref_head_name = types.StringAttribute{
    .name = "vcs.ref.head.name",
    .brief = "The name of the [reference](https://git-scm.com/docs/gitglossary#def_ref) such as **branch** or **tag** in the repository.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The revision, literally [revised version](https://www.merriam-webster.com/dictionary/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.
///
/// # Examples
///
/// - 9d59409acf479dfa0df1aa568182e43e43df8bbe28d60fcf2bc52e30068802cc
/// - main
/// - 123
/// - HEAD
/// Note: This attribute is experimental and may change in the future.
pub const vcs_ref_head_revision = types.StringAttribute{
    .name = "vcs.ref.head.revision",
    .brief = "The revision, literally [revised version](https://www.merriam-webster.com/dictionary/revision), The revision most often refers to a commit object in Git, or a revision number in SVN.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.
///
/// # Examples
///
/// - branch
/// - tag
/// Note: This attribute is experimental and may change in the future.
pub const vcs_ref_type = types.StringAttribute{
    .name = "vcs.ref.type",
    .brief = "The type of the [reference](https://git-scm.com/docs/gitglossary#def_ref) in the repository.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The human readable name of the repository. It SHOULD NOT include any additional identifier like Group/SubGroup in GitLab or organization in GitHub.
///
/// # Examples
///
/// - semantic-conventions
/// - my-cool-repo
/// Note: This attribute is experimental and may change in the future.
pub const vcs_repository_name = types.StringAttribute{
    .name = "vcs.repository.name",
    .brief = "The human readable name of the repository. It SHOULD NOT include any additional identifier like Group/SubGroup in GitLab or organization in GitHub.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The [canonical URL](https://support.google.com/webmasters/answer/10347851?hl=en#:~:text=A%20canonical%20URL%20is%20the,Google%20chooses%20one%20as%20canonical.) of the repository providing the complete HTTP(S) address in order to locate and identify the repository through a browser.
///
/// # Examples
///
/// - https://github.com/opentelemetry/open-telemetry-collector-contrib
/// - https://gitlab.com/my-org/my-project/my-projects-project/repo
/// Note: This attribute is experimental and may change in the future.
pub const vcs_repository_url_full = types.StringAttribute{
    .name = "vcs.repository.url.full",
    .brief = "The [canonical URL](https://support.google.com/webmasters/answer/10347851?hl=en#:~:text=A%20canonical%20URL%20is%20the,Google%20chooses%20one%20as%20canonical.) of the repository providing the complete HTTP(S) address in order to locate and identify the repository through a browser.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// Additional description of the web engine (e.g. detailed version and edition information).
///
/// # Examples
///
/// - WildFly Full 21.0.0.Final (WildFly Core 13.0.1.Final) - 2.2.2.Final
/// Note: This attribute is experimental and may change in the future.
pub const webengine_description = types.StringAttribute{
    .name = "webengine.description",
    .brief = "Additional description of the web engine (e.g. detailed version and edition information).",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The name of the web engine.
///
/// # Examples
///
/// - WildFly
/// Note: This attribute is experimental and may change in the future.
pub const webengine_name = types.StringAttribute{
    .name = "webengine.name",
    .brief = "The name of the web engine.",
    .stability = .development,
    .requirement_level = .required,
};

/// The version of the web engine.
///
/// # Examples
///
/// - 21.0.0
/// Note: This attribute is experimental and may change in the future.
pub const webengine_version = types.StringAttribute{
    .name = "webengine.version",
    .brief = "The version of the web engine.",
    .stability = .development,
    .requirement_level = .recommended,
};

/// The System Management Facility (SMF) Identifier uniquely identified a z/OS system within a SYSPLEX or mainframe environment and is used for system and performance analysis.
///
/// # Examples
///
/// - SYS1
/// Note: This attribute is experimental and may change in the future.
pub const zos_smf_id = types.StringAttribute{
    .name = "zos.smf.id",
    .brief = "The System Management Facility (SMF) Identifier uniquely identified a z/OS system within a SYSPLEX or mainframe environment and is used for system and performance analysis.",
    .stability = .development,
    .requirement_level = .required,
};

/// The name of the SYSPLEX to which the z/OS system belongs too.
///
/// # Examples
///
/// - SYSPLEX1
/// Note: This attribute is experimental and may change in the future.
pub const zos_sysplex_name = types.StringAttribute{
    .name = "zos.sysplex.name",
    .brief = "The name of the SYSPLEX to which the z/OS system belongs too.",
    .stability = .development,
    .requirement_level = .required,
};

test "semantic resource attributes" {
    @import("std").testing.refAllDecls(@This());
}
