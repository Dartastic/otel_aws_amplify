// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_amplify/otel_aws_amplify.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_amplify', () {
    test('suppression toggles in zone', () async {
      expect(awsAmplifyInstrumentationSuppressed(), isFalse);
      await runWithoutAwsAmplifyInstrumentationAsync(() async {
        expect(awsAmplifyInstrumentationSuppressed(), isTrue);
      });
      expect(awsAmplifyInstrumentationSuppressed(), isFalse);
    });

    test('AwsAmplifyResult fields default null', () {
      const r = AwsAmplifyResult();
      expect(r.statusCode, isNull);
    });
  });
}
