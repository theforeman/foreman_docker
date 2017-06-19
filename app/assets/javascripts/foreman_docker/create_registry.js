function toggleVerifySSL () {
  var urlField = $('#docker_registry_url'),
      verifySSLField = $('#docker_registry_verify_ssl'),
      verifySSLFormGroup = verifySSLField.closest('.form-group');

  if (/^https/.test(urlField.val())) {
    verifySSLFormGroup.show();
  } else {
    verifySSLFormGroup.hide();
  };
};

$(document).ready(function () {
  $('#docker_registry_url').on('change', toggleVerifySSL)
})
