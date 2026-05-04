/**
 * @description Evaluates feature flags using Custom Permissions (user-level) and
 *              FeatureFlag__mdt Custom Metadata Type records (org-level). Also supports
 *              mocked values for test contexts via setMockValue.
 * @testclass FeatureFlagsTests
 */
public with sharing class FeatureFlags implements IFeatureFlags {

    private Map<String, FeatureFlag__mdt> features;
    private Set<String> customPermissionNames;
    private static Map<String, Boolean> mockValues = new Map<String, Boolean>();

    /**
     * @description Constructs a FeatureFlags instance using the supplied provider so that
     *              Custom Permissions and Feature Flag metadata can be injected for testing
     * @param provider Provider implementation that returns permissions and metadata records
     */
    public FeatureFlags(IFeatureFlagProvider provider) {
        features = provider.getFeatureFlags();
        customPermissionNames = provider.getCustomPermissionNames();
    }

    /**
     * @description Default constructor that uses the production FeatureFlagProvider,
     *              which reads live Custom Permissions and FeatureFlag__mdt records
     */
    public FeatureFlags() {
        this(new FeatureFlagProvider());
    }

    /**
     * @description Evaluates a feature flag by first checking for a matching Custom Permission,
     *              then falling back to a matching FeatureFlag__mdt record. Mock values set via
     *              setMockValue take precedence when running in a test context.
     * @param featureName Developer name of the Custom Permission or FeatureFlag__mdt record
     * @return FeatureEvaluationResult describing whether the flag is enabled and why
     */
    public FeatureEvaluationResult evaluate(String featureName) {
        if (Test.isRunningTest() && mockValues.containsKey(featureName)) {
            return new FeatureEvaluationResult(mockValues.get(featureName), featureName, FeatureReason.MOCK_VALUE);
        }

        FeatureEvaluationResult result;

        if (customPermissionNames.contains(featureName)) {
            if (FeatureManagement.checkPermission(featureName)) {
                result = new FeatureEvaluationResult(true, featureName, FeatureReason.HAS_CUSTOM_PERMISSION);
            } else {
                result = new FeatureEvaluationResult(false, featureName, FeatureReason.MISSING_CUSTOM_PERMISSION);
            }
        } else {
            if (features.containsKey(featureName)) {
                if (features.get(featureName).Is_Active__c) {
                    result = new FeatureEvaluationResult(true, featureName, FeatureReason.CUSTOM_METADATA_TYPE_ENABLED);
                } else {
                    result = new FeatureEvaluationResult(false, featureName, FeatureReason.CUSTOM_METADATA_TYPE_DISABLED);
                }
            } else {
                result = new FeatureEvaluationResult(false, featureName, FeatureReason.FLAG_NOT_FOUND);
            }
        }

        return result;
    }

    /**
     * @description Exposes feature flag evaluation to Lightning Web Components, returning only
     *              the boolean enabled state. Cached to minimize server round-trips.
     * @param featureName Developer name of the Custom Permission or FeatureFlag__mdt record
     * @return True if the feature flag is enabled for the running user, false otherwise
     */
    @AuraEnabled(cacheable=true)
    public static Boolean lwcEvaluate(String featureName) {
        return new FeatureFlags().evaluate(featureName).isEnabled();
    }

    /**
     * @description Sets a mocked value for a feature flag that will be returned by evaluate
     *              when running in a test context, bypassing permission and metadata lookups
     * @param featureName Developer name of the feature flag to mock
     * @param value Boolean value to return for the feature flag in tests
     */
    @TestVisible
    private static void setMockValue(String featureName, Boolean value) {
        mockValues.put(featureName, value);
    }

    /**
     * @description Immutable result of a feature flag evaluation, exposing the enabled state,
     *              the feature name evaluated, and the reason the evaluation resolved as it did
     */
    public class FeatureEvaluationResult {

        private Boolean result;
        private String featureName;
        private FeatureReason reason;

        /**
         * @description Returns whether the feature flag is enabled for the running user
         * @return True if the feature flag is enabled, false otherwise
         */
        public Boolean isEnabled() {
            return result;
        }

        /**
         * @description Returns the developer name of the feature flag that was evaluated
         * @return Developer name of the evaluated feature flag
         */
        public String getFeatureName() {
            return featureName;
        }

        /**
         * @description Returns the reason code describing how the evaluation resolved, useful
         *              for logging and troubleshooting unexpected flag behavior
         * @return FeatureReason enum value indicating why the result was produced
         */
        public FeatureReason getReason() {
            return reason;
        }

        /**
         * @description Constructs a FeatureEvaluationResult with the evaluation outcome,
         *              the feature name, and the reason code
         * @param result Boolean result of the evaluation
         * @param featureName Developer name of the feature flag that was evaluated
         * @param reason FeatureReason enum value describing why the result was produced
         */
        public FeatureEvaluationResult(Boolean result, String featureName, FeatureReason reason) {
            this.result = result;
            this.featureName = featureName;
            this.reason = reason;
        }
    }

    /**
     * @description Enumerates the possible reasons a feature flag evaluation resolved the way
     *              it did, covering Custom Permission presence, Custom Metadata Type state,
     *              missing flags, and mocked test values
     */
    public enum FeatureReason {
        HAS_CUSTOM_PERMISSION,
        MISSING_CUSTOM_PERMISSION,
        CUSTOM_METADATA_TYPE_ENABLED,
        CUSTOM_METADATA_TYPE_DISABLED,
        FLAG_NOT_FOUND,
        MOCK_VALUE
    }
}
