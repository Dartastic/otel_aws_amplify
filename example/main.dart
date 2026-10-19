// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_amplify/otel_aws_amplify.dart';

/// Traces Aws Amplify calls with OpenTelemetry.
///
/// `otel_aws_amplify` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Amplify call in
/// [tracedAwsAmplify]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-amplify-example');

  // Traces a Aws Amplify call.
  final awsAmplifyId = await tracedAwsAmplify<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Amplify call here, then report what it returned.
      const id = 'aws_amplify_8f3a2c';
      return const AwsAmplifyCallResult(
          value: id,
          result: AwsAmplifyResult(
              appId: 'app_8f3a2c',
              appName: 'example',
              branchName: 'example',
              jobId: 'job_8f3a2c',
              jobType: 'standard',
              jobStatus: 'succeeded',
              artifactsUrl: 'https://api.example.com/v1/resource',
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsAmplify create returned $awsAmplifyId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsAmplifyInstrumentationAsync.
  await runWithoutAwsAmplifyInstrumentationAsync(
    () => tracedAwsAmplify<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_amplify_8f3a2c';
        return const AwsAmplifyCallResult(
            value: id,
            result: AwsAmplifyResult(
                appId: 'app_8f3a2c',
                appName: 'example',
                branchName: 'example',
                jobId: 'job_8f3a2c',
                jobType: 'standard',
                jobStatus: 'succeeded',
                artifactsUrl: 'https://api.example.com/v1/resource',
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
