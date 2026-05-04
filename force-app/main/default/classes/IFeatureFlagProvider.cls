/**
 * @description Interface for sourcing feature flag configuration, returning the set of
 *              Custom Permission developer names and the map of FeatureFlag__mdt records.
 *              Allows the FeatureFlags class to be decoupled from the database for testing.
 * @testclass FeatureFlagsTests
 */
public interface IFeatureFlagProvider {
    /**
     * @description Returns the developer names of all Custom Permissions available in the org
     * @return Set of Custom Permission developer names
     */
    Set<String> getCustomPermissionNames();

    /**
     * @description Returns all FeatureFlag__mdt records keyed by developer name
     * @return Map of developer name to FeatureFlag__mdt record
     */
    Map<String, FeatureFlag__mdt> getFeatureFlags();
}
