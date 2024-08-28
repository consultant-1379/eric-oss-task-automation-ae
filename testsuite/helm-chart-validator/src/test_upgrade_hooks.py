"""This module contains test cases to verify that the templates use the correct hooks strategy."""

import pytest
from datetime import date
from utils import mark_test_parameters
from helm_template import HelmTemplate

helm_template_object = HelmTemplate("/eric-oss-task-automation-ae.tgz", "/testsuite/site_values.yaml")
annotations = helm_template_object.get_values_with_a_specific_path("metadata.annotations")


marks = [
    (['eric-oss-flow-automation-db-pg-hkln-inventory'], ['Secret'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-hkln-postin'], ['Job'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-log-shipper-'], ['Job'], pytest.mark.skip(reason='Not required, exempt'))
]
test_parameters = mark_test_parameters(annotations, marks)


@pytest.mark.parametrize(('template', 'kind', 'annotation'), test_parameters)
def test_postUpgrade_is_used_in_postInstall_service_hook(template, kind, annotation):
    """Test that post-upgrade is in the metadata.annotations of all Hooks marked for post-install."""
    helm_hook = annotation.get('helm.sh/hook')
    if helm_hook:
        if "post-install" in helm_hook:
            assert 'post-upgrade' in helm_hook


marks = [
    (['eric-oss-flow-automation-db-pg-hkln-postu'], ['Job'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-log-shipper-'], ['Job'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-ls-hook-log-shipper-sidecar'], ['ConfigMap'], pytest.mark.skip(reason='Not required, exempt'))
 ]
test_parameters = mark_test_parameters(annotations, marks)


@pytest.mark.parametrize(('template', 'kind', 'annotation'), test_parameters)
def test_postInstall_is_used_in_post_Upgrade_service_hook(template, kind, annotation):
    """Test that post-install is in the metadata.annotations of all Hooks marked for post-upgrade."""
    helm_hook = annotation.get('helm.sh/hook')
    if helm_hook:
        if "post-upgrade" in helm_hook:
            assert 'post-install' in helm_hook


marks = [
    (['-db$'], ['Role', 'RoleBinding'],
     pytest.mark.xfail(date.today() < date(2020, 8, 18),
                       reason='https://cc-jira.rnd.ki.sw.ericsson.se/browse/ADPPRG-29560')),
    (['eric-oss-flow-automation-db-pg-backup-pgdata'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
]
test_parameters = mark_test_parameters(annotations, marks)


@pytest.mark.parametrize(('template', 'kind', 'annotation'), test_parameters)
def test_preUpgrade_is_used_in_preInstall_service_hook(template, kind, annotation):
    """Test that pre-upgrade is in the metadata.annotations of all Hooks marked for pre-install."""
    helm_hook = annotation.get('helm.sh/hook')
    if helm_hook:
        if "pre-install" in helm_hook:
            assert 'pre-upgrade' in helm_hook


marks = [
    (['eric-oss-flow-automation-db-pg-pgdata-hook'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-pgdata-hook'], ['Role'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-pgdata-hook'], ['RoleBinding'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-dispatch'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-hkln-inventory'], ['Secret'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-dispatch'], ['Role'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-hkln-stepu'], ['Job'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-dispatch'], ['RoleBinding'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-dispatch'], ['Job'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-hkln-preup'], ['Job'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-op-dispatch'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-op-dispatch'], ['Role'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-op-dispatch'], ['RoleBinding'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-preup-cmupdate'], ['ServiceAccount'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-preup-cmupdate'], ['Role'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-oss-flow-automation-db-pg-preup-cmupdate'], ['RoleBinding'], pytest.mark.skip(reason='Not required, exempt')),
    (['eric-log-shipper-'], ['Job'], pytest.mark.skip(reason='Not required, exempt'))    
]
test_parameters = mark_test_parameters(annotations, marks)


@pytest.mark.parametrize(('template', 'kind', 'annotation'), test_parameters)
def test_preInstall_is_used_in_preUpgrade_service_hook(template, kind, annotation):
    """Test that pre-install is in the metadata.annotations of all Hooks marked for pre-upgrade."""
    helm_hook = annotation.get('helm.sh/hook')
    if helm_hook:
        if "pre-upgrade" in helm_hook:
            assert 'pre-install' in helm_hook
