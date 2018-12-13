#/bin/sh
#
# SPDX-License-Identifier: Apache-2.0

# Don't change -- ansible playbook has this hardcoded
MEDIA_DIR=~/igc-media

ANSIBLE_USER_DIR=~/ansible-playbook

# Also hardcoded - search below & change
#VOL_DEV=/dev/vdb

# Check for media (dir only)
if [[ ! -d $MEDIA_DIR ]]
then
	echo "Remember to download media files for IGC!"
	exit 1
fi

# -- Not needed for basic IGC
# Check for volume
#if [[ ! -b $VOL_DEV ]]
#then
#	echo "Remember to create raw device for IGC!"
#	exit 1
#fi

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
mkdir -p ${ANSIBLE_USER_DIR}/roles
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to create ansible directory"
  exit 1
fi

cd ${ANSIBLE_USER_DIR}/roles
if [[ $rc -ne 0 ]]
then
  echo "Failed to switch to ansible directory"
  exit 1
fi

rm -fr ${ANSIBLE_USER_DIR}/roles/IBM.infosvr-metadata-asset-manager
git clone https://github.com/IBM/ansible-role-infosvr-metadata-asset-manager.git IBM.infosvr-metadata-asset-manager
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to clone imam ansible project"
  exit 1
fi

rm -fr ${ANSIBLE_USER_DIR}/roles/IBM.infosvr
git clone https://github.com/IBM/ansible-role-infosvr.git IBM.infosvr
rc=$?
if [[ $rc -ne 0 ]]
then
  echo "Failed to clone infosvr git project"
  exit 1
fi

cat > ${ANSIBLE_USER_DIR}/inventory <<END
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

cat > ${ANSIBLE_USER_DIR}/install.yaml <<END
- name: install and configure IBM InfoSphere Information Server
  hosts: all
  any_errors_fatal: true
  roles:
    - IBM.infosvr
  connection: local
  vars:
    ibm_infosvr_ug_storage: /dev/vdb
    ibm_infosvr_media_dir: ../igc-media
    ibm_infosvr_media_bin: {   server_tarball: "IS_V11702_Linux_x86_multi.tar.gz", ug_tarball: "is-enterprise-search-11.7.0.2.tar.gz", client_zip: "IS_V11.7.0.2_WINDOWS_CLIENT.zip", entitlements: "IS_V11702_bundle_spec_file_multi.zip" }
    ibm_infosvr_features: { opsdb: False, ia: False, igc: True, dataclick: False, event_mgmt: False, qs: False, wisd: False, fasttrack: False, dqec: False, igd: False, wlp: False, ises: False, ml_term_assignment: False, omag: False }
    ibm_infosvr_force: { repo: True, domain: False, engine: False, client: False, patch: True }
END
if [[ $rc -ne 0 ]]
then
  echo "Failed to create ansible playbook"
  exit 1
fi

cd ${ANSIBLE_USER_DIR}
if [[ $rc -ne 0 ]]
then
  echo "Failed to switch back to playbook before installing"
  exit 1
fi

echo "----"
echo "Ready to install...."
echo "run:"
echo "----"
ansible-playbook -b -i inventory install.yaml
