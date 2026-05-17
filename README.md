# otel_aws_amplify

Dartastic OpenTelemetry bridge for AWS Amplify (full-stack mobile + web platform).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_amplify/otel_aws_amplify.dart';

await tracedAwsAmplify<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsAmplifyCallResult(value: r, result: AwsAmplifyResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsAmplifyInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
