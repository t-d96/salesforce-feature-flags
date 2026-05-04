/**
 * @description Interface for feature flag evaluators. Enables dependency injection of
 *              real or mocked implementations so callers can be unit tested without
 *              relying on live Custom Permissions or Custom Metadata Type records.
 * @testclass FeatureFlagsTests
 */
public interface IFeatureFlags {
    /**
     * @description Evaluates a feature flag and returns a result describing the outcome
     * @param featureName Developer name of the Custom Permission or FeatureFlag__mdt record
     * @return FeatureEvaluationResult describing whether the flag is enabled and why
     */
    FeatureFlags.FeatureEvaluationResult evaluate(String featureName);
}
