/**
 * @description Test class for FeatureFlags
 */
@IsTest
private class FeatureFlagsTests {
    @IsTest
    static void testFeatureEnabledWithCustomMetadata() {
        FeatureFlagProviderMock mockFlags = new FeatureFlagProviderMock();
        FeatureFlags flags = new FeatureFlags(mockFlags);

        Test.startTest();
        FeatureFlags.FeatureEvaluationResult result = flags.evaluate('flag1');
        Test.stopTest();

        Assert.isTrue(result.isEnabled(), 'Flag should be enabled when custom metadata Is_Active__c is true');
        Assert.areEqual('flag1', result.getFeatureName(), 'Feature name should match the evaluated flag');
        Assert.areEqual(
            FeatureFlags.FeatureReason.CUSTOM_METADATA_TYPE_ENABLED,
            result.getReason(),
            'Reason should be CUSTOM_METADATA_TYPE_ENABLED when flag is active via metadata'
        );
    }

    @IsTest
    static void testFeatureDisabledWithCustomMetadata() {
        FeatureFlagProviderMock mockFlags = new FeatureFlagProviderMock();
        FeatureFlags flags = new FeatureFlags(mockFlags);

        Test.startTest();
        FeatureFlags.FeatureEvaluationResult result = flags.evaluate('flag2');
        Test.stopTest();

        Assert.isFalse(result.isEnabled(), 'Flag should be disabled when custom metadata Is_Active__c is false');
        Assert.areEqual('flag2', result.getFeatureName(), 'Feature name should match the evaluated flag');
        Assert.areEqual(
            FeatureFlags.FeatureReason.CUSTOM_METADATA_TYPE_DISABLED,
            result.getReason(),
            'Reason should be CUSTOM_METADATA_TYPE_DISABLED when flag is inactive via metadata'
        );
    }

    @IsTest
    static void testFeatureDisabledWithMissingCustomPermission() {
        FeatureFlagProviderMock mockFlags = new FeatureFlagProviderMock();
        FeatureFlags flags = new FeatureFlags(mockFlags);

        Test.startTest();
        FeatureFlags.FeatureEvaluationResult result = flags.evaluate('permission1');
        Test.stopTest();

        Assert.isFalse(result.isEnabled(), 'Flag should be disabled when user lacks the custom permission');
        Assert.areEqual('permission1', result.getFeatureName(), 'Feature name should match the evaluated flag');
        Assert.areEqual(
            FeatureFlags.FeatureReason.MISSING_CUSTOM_PERMISSION,
            result.getReason(),
            'Reason should be MISSING_CUSTOM_PERMISSION when user does not have the permission'
        );
    }

    @IsTest
    static void testFeatureNotFound() {
        FeatureFlagProviderMock mockFlags = new FeatureFlagProviderMock();
        FeatureFlags flags = new FeatureFlags(mockFlags);

        Test.startTest();
        FeatureFlags.FeatureEvaluationResult result = flags.evaluate('RandomFeature');
        Test.stopTest();

        Assert.isFalse(result.isEnabled(), 'Flag should be disabled when no matching permission or metadata exists');
        Assert.areEqual('RandomFeature', result.getFeatureName(), 'Feature name should match the evaluated flag');
        Assert.areEqual(
            FeatureFlags.FeatureReason.FLAG_NOT_FOUND,
            result.getReason(),
            'Reason should be FLAG_NOT_FOUND when flag has no matching permission or metadata'
        );
    }

    @IsTest
    static void testFeatureFlagProvider() {
        FeatureFlagProvider provider = new FeatureFlagProvider();

        Test.startTest();
        Set<String> permissionNames = provider.getCustomPermissionNames();
        Map<String, FeatureFlag__mdt> flags = provider.getFeatureFlags();
        Test.stopTest();

        Assert.isNotNull(permissionNames, 'Provider should return a non-null set of custom permission names');
        Assert.isNotNull(flags, 'Provider should return a non-null map of feature flags');
    }

    @IsTest
    static void testMockValues() {
        FeatureFlags.setMockValue('mockedFeatureValue', true);

        Test.startTest();
        FeatureFlags flags = new FeatureFlags();
        FeatureFlags.FeatureEvaluationResult result = flags.evaluate('mockedFeatureValue');
        Test.stopTest();

        Assert.isTrue(result.isEnabled(), 'Flag should be enabled when mock value is set to true');
        Assert.areEqual('mockedFeatureValue', result.getFeatureName(), 'Feature name should match the evaluated flag');
        Assert.areEqual(
            FeatureFlags.FeatureReason.MOCK_VALUE,
            result.getReason(),
            'Reason should be MOCK_VALUE when evaluation returns a mocked result'
        );
    }
}
