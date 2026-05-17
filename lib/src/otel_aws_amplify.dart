// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_amplify_suppression.dart';

class AwsAmplifyResult {
  const AwsAmplifyResult({
    this.appId,
    this.appName,
    this.branchName,
    this.jobId,
    this.jobType,
    this.jobStatus,
    this.artifactsUrl,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? appId;
  final String? appName;
  final String? branchName;
  final String? jobId;
  final String? jobType;
  final String? jobStatus;
  final String? artifactsUrl;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsAmplifyCallResult<T> {
  const AwsAmplifyCallResult({required this.value, this.result});
  final T value;
  final AwsAmplifyResult? result;
}

Future<T> tracedAwsAmplify<T>({
  required String operation,
  required Future<AwsAmplifyCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsAmplifyInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_amplify');
  final span = t.startSpan('amplify $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'aws-api');
    span.setStringAttribute('rpc.service', 'Amplify');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.appId != null) {
        span.setStringAttribute('aws.amplify.app.id', res.appId!);
      }
      if (res.appName != null) {
        span.setStringAttribute('aws.amplify.app.name', res.appName!);
      }
      if (res.branchName != null) {
        span.setStringAttribute('vcs.ref.head.name', res.branchName!);
      }
      if (res.jobId != null) {
        span.setStringAttribute('aws.amplify.job.id', res.jobId!);
      }
      if (res.jobType != null) {
        span.setStringAttribute('aws.amplify.job.type', res.jobType!);
      }
      if (res.jobStatus != null) {
        span.setStringAttribute('aws.amplify.job.status', res.jobStatus!);
      }
      if (res.artifactsUrl != null) {
        span.setStringAttribute('aws.amplify.artifacts_url', res.artifactsUrl!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('amplify.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'amplify.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
