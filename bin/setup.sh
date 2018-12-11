#/bin/sh
#
# SPDX-License-Identifier: Apache-2.0

sudo yum -y update
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to apply updates - check sudo/root"
  exit 1
fi

sudo yum -y install git ansible
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to install git - check sudo/root"
  exit 1
fi

cd
mkdir -p ~/ansible-playbook/roles
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to create ansible directory"
  exit 1
fi

cd ~/ansible-playbook/roles
if [[ $rc -ne 0 ]]
then
  echo "Failed to switch to ansible directory"
  exit 1
fi

rm -fr ~/ansible-playbook/roles/IBM.infosvr-metadata-asset-manager
git clone https://github.com/IBM/ansible-role-infosvr-metadata-asset-manager.git IBM.infosvr-metadata-asset-manager
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to clone imam ansible project"
  exit 1
fi

rm -fr ~/ansible-playbook/roles/IBM.infosvr
git clone https://github.com/IBM/ansible-role-infosvr.git IBM.infosvr
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to clone infosvr git project"
  exit 1
fi

mkdir -p ~/ansible-playbook
if [[ $rc -ne 0 ]]
then
  echo "Failed to create ansible playbook dir"
  exit 1
fi

cat > ~/ansible-playbook/inventory <<END
[ibm-information-server-repo]
igc.novalocal
[ibm-information-server-domain]
igc.novalocal
[ibm-information-server-engine]
igc.novalocal
[ibm-information-server-clients]
[ibm-information-server-ug]
[ibm-cognos-report-server]
[ibm-bpm]
END

if [[ $rc -ne 0 ]]
then
  echo "Failed to create ansible inventory"
  exit 1
fi

cat > ~/ansible-playbook/install.yaml <<END
- name: install and configure IBM InfoSphere Information Server
  hosts: all
  any_errors_fatal: true
  roles:
    - IBM.infosvr
  connection: local
  vars:
    ibm_infosvr_ug_storage: /dev/vdb
    ibm_infosvr_media_dir: media
    ibm_infosvr_media_bin: {   server_tarball: "IS_V11702_Linux_x86_multi.tar.gz", ug_tarball: "is-enterprise-search-11.7.0.2.tar.gz", client_zip: "IS_V11.7.0.2_WINDOWS_CLIENT.zip", entitlements: "IS_V11702_bundle_spec_file_multi.zip" }
    ibm_infosvr_features: { opsdb: False, ia: False, igc: True, dataclick: False, event_mgmt: True, qs: False, wisd: False, fasttrack: False, dqec: False, igd: False, wlp: True, ises: False, ml_term_assignment: False, omag: False }
END
if [[ $rc -ne 0 ]]
then
  echo "Failed to create ansible playbook"
  exit 1
fi

cd ~/ansible-playbook
echo "----"
echo "Ready to install...."
echo "run:"
echo "cd ~/ansible-playbook"
echo "ansible-playbook -b -i inventory install.yaml"
echo "----"
