module ContainerStepsHelper
  def container_wizard(step)
    wizard_header(
      step,
      _('Resource'),
      _('Image'),
      _('Configuration'),
      _('Environment')
    )
  end
end
