// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_amplify_suppression.dart';

class AwsAmplifyResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AwsAmplifyCallResult<T> {
  /// Creates a call result.
  const AwsAmplifyCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AwsAmplifyResult? result;
}

Future<T> tracedAwsAmplify<T>({
  required String operation,
  required Future<AwsAmplifyCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsAmplifyInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_amplify');
  final span = t.startSpan('amplify $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'aws-api')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.service', 'Amplify')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.appId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.amplify.app.id', res.appId!)]));
      }
      if (res.appName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.amplify.app.name', res.appName!)]));
      }
      if (res.branchName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('vcs.ref.head.name', res.branchName!)]));
      }
      if (res.jobId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.amplify.job.id', res.jobId!)]));
      }
      if (res.jobType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.amplify.job.type', res.jobType!)]));
      }
      if (res.jobStatus != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('aws.amplify.job.status', res.jobStatus!)
        ]));
      }
      if (res.artifactsUrl != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'aws.amplify.artifacts_url', res.artifactsUrl!)
        ]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('amplify.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'amplify.error',
          )
        ]));
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
