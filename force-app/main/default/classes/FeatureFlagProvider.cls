/**
 * @description Production implementation of IFeatureFlagProvider that sources Custom Permission
 *              developer names and FeatureFlag__mdt records directly from the org
 * @testclass FeatureFlagsTests
 */
public with sharing class FeatureFlagProvider implements IFeatureFlagProvider {

    /**
     * @description Queries all Custom Permissions in the org and returns their developer names
     * @return Set of Custom Permission developer names available in the org
     */
    public Set<String> getCustomPermissionNames() {
        Set<String> customPermissionNames = new Set<String>();
        List<CustomPermission> perms = [SELECT Id, DeveloperName FROM CustomPermission];
        for (CustomPermission perm : perms) {
            customPermissionNames.add(perm.DeveloperName);
        }
        return customPermissionNames;
    }

    /**
     * @description Returns all FeatureFlag__mdt records in the org keyed by developer name
     * @return Map of developer name to FeatureFlag__mdt record
     */
    public Map<String, FeatureFlag__mdt> getFeatureFlags() {
        return FeatureFlag__mdt.getAll();
    }
}
