/**
 * @description Mock implementation of IFeatureFlags that resolves feature flag evaluations
 *              from a supplied Map, allowing consumers of IFeatureFlags to be unit tested
 *              without touching Custom Permissions or Custom Metadata Types
 * @testclass FeatureFlagsTests
 */
public with sharing class FeatureFlagsMock implements IFeatureFlags {

    private Map<String, Boolean> featureMap;

    /**
     * @description Constructs the mock with a map of feature name to enabled state
     * @param featureMap Map of feature flag developer names to their mocked enabled state
     */
    public FeatureFlagsMock(Map<String, Boolean> featureMap) {
        this.featureMap = featureMap;
    }

    /**
     * @description Returns a FeatureEvaluationResult built from the mock map. Features not
     *              present in the map resolve to false.
     * @param featureName Developer name of the feature flag to evaluate
     * @return FeatureEvaluationResult reflecting the mocked state for the feature
     */
    public FeatureFlags.FeatureEvaluationResult evaluate(String featureName) {
        Boolean isActive = featureMap.containsKey(featureName) ? featureMap.get(featureName) : false;
        return new FeatureFlags.FeatureEvaluationResult(isActive, featureName, null);
    }
}
