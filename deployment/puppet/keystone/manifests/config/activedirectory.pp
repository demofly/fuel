class keystone::config::activedirectory (
    $url                        = 'ldap://127.0.0.1',
    $user                       = 'CN=ldap,CN=Users,DC=fuel-pm,DC=com',
    $password                   = 'R00tme11',
    $suffix                     = 'DC=fuel-pm,DC=com',
    $user_tree_dn               = 'CN=Users,DC=fuel-pm,DC=com',
    $user_objectclass           = 'organizationalPerson',
    $user_id_attribute          = 'CN',
    $user_name_attribute        = 'cn',
    $user_mail_attribute        = 'mail',
    $user_enabled_attribute     = 'userAccountControl',
    $user_enabled_mask          = '2',
    $user_enabled_default       = '512',
    $user_attribute_ignore      = 'password,tenant_id,tenants',
    $user_allow_create          = 'False',
    $user_allow_update          = 'False',
    $user_allow_delete          = 'False',
    $tenant_tree_dn             = 'OU=Projects,OU=Openstack,DC=fuel-pm,DC=com',
    $tenant_objectclass         = 'organizationalUnit',
    $tenant_id_attribute     	= 'OU',
    $tenant_member_attribute  	= 'member',
    $tenant_name_attribute    	= 'ou',
    $tenant_desc_attribute    	= 'description',
    $tenant_enabled_attribute 	= 'extensionName',
    $tenant_attribute_ignore  	= 'businessCategory,extensionName',
    $tenant_allow_create      	= 'False',
    $tenant_allow_update      	= 'False',
    $tenant_allow_delete      	= 'False',
    $role_tree_dn               = 'OU=Roles,OU=Openstack,DC=fuel-pm,DC=com',
    $role_objectclass         	= 'organizationalRole',
    $role_id_attribute        	= 'cn',
    $role_name_attribute      	= 'ou',
    $role_member_attribute    	= 'roleOccupant',
    $role_allow_create        	= 'False',
    $role_allow_update        	= 'False',
    $role_allow_delete        	= 'False'
) {

  # Validate
    
  if empty($url) {
    fail('$url is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user) {
    fail('$user is not defined in keystone::config::ActiveDirectory')
  }

  if empty($password) {
    fail('$password is not defined in keystone::config::ActiveDirectory')
  }

  if empty($suffix) {
    fail('$suffix is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_tree_dn) {
    fail('$user_tree_dn is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_objectclass) {
    fail('$user_objectclass is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_id_attribute) {
    fail('$user_id_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_name_attribute) {
    fail('$user_name_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_mail_attribute) {
    fail('$user_mail_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_enabled_attribute) {
    fail('$user_enabled_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_enabled_mask) {
    fail('$user_enabled_mask is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_enabled_default) {
    fail('$user_enabled_default is not defined in keystone::config::ActiveDirectory')
  }

  if empty($user_attribute_ignore) {
    fail('$user_attribute_ignore is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_tree_dn) {
    fail('$tenant_tree_dn is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_objectclass) {
    fail('$tenant_objectclass is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_id_attribute) {
    fail('$tenant_id_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_member_attribute) {
    fail('$tenant_member_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_name_attribute) {
    fail('$tenant_name_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_desc_attribute) {
    fail('$tenant_desc_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_enabled_attribute) {
    fail('$tenant_enabled_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($tenant_attribute_ignore) {
    fail('$tenant_attribute_ignore is not defined in keystone::config::ActiveDirectory')
  }

  if empty($role_tree_dn) {
    fail('$role_tree_dn is not defined in keystone::config::ActiveDirectory')
  }

  if empty($role_objectclass) {
    fail('$role_objectclass is not defined in keystone::config::ActiveDirectory')
  }

  if empty($role_id_attribute) {
    fail('$role_id_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($role_name_attribute) {
    fail('$role_name_attribute is not defined in keystone::config::ActiveDirectory')
  }

  if empty($role_member_attribute) {
    fail('$role_member_attribute is not defined in keystone::config::ActiveDirectory')
  }

  keystone_config {
    'ldap/url':                         value => $url;
    'ldap/user':                        value => $user;
    'ldap/password':                    value => $password;
    'ldap/suffix':                      value => $suffix;
    'ldap/user_tree_dn':                value => $user_tree_dn;
    'ldap/user_objectclass':            value => $user_objectclass;
    'ldap/user_id_attribute':           value => $user_id_attribute;
    'ldap/user_name_attribute':         value => $user_name_attribute;
    'ldap/user_mail_attribute':         value => $user_mail_attribute;
    'ldap/user_enabled_attribute':      value => $user_enabled_attribute;
    'ldap/user_enabled_mask':           value => $user_enabled_mask;
    'ldap/user_enabled_default':        value => $user_enabled_default;
    'ldap/user_attribute_ignore':       value => $user_attribute_ignore;
    'ldap/user_allow_create':           value => $user_allow_create;
    'ldap/user_allow_update':           value => $user_allow_update;
    'ldap/user_allow_delete':           value => $user_allow_delete;
    'ldap/tenant_tree_dn':              value => $tenant_tree_dn;
    'ldap/tenant_objectclass':          value => $tenant_objectclass;
    'ldap/tenant_id_attribute':         value => $tenant_id_attribute;
    'ldap/tenant_member_attribute':     value => $tenant_member_attribute;
    'ldap/tenant_name_attribute':       value => $tenant_name_attribute;
    'ldap/tenant_desc_attribute':       value => $tenant_desc_attribute;
    'ldap/tenant_enabled_attribute':	value => $tenant_enabled_attribute;
    'ldap/tenant_attribute_ignore':     value => $tenant_attribute_ignore;
    'ldap/tenant_allow_create':         value => $tenant_allow_create;
    'ldap/tenant_allow_update':         value => $tenant_allow_update;
    'ldap/tenant_allow_delete':         value => $tenant_allow_delete;
    'ldap/role_tree_dn':                value => $role_tree_dn;
    'ldap/role_objectclass':            value => $role_objectclass;
    'ldap/role_id_attribute':           value => $role_id_attribute;
    'ldap/role_name_attribute':         value => $role_name_attribute;
    'ldap/role_member_attribute':       value => $role_member_attribute;
    'ldap/role_allow_create':           value => $role_allow_create;
    'ldap/role_allow_update':           value => $role_allow_update;
    'ldap/role_allow_delete':           value => $role_allow_delete;
  }
}
