from ansible.plugins.callback.yaml import CallbackModule as YamlCallbackModule

class CallbackModule(YamlCallbackModule):

    """
    Variation of the Default output which uses nicely readable YAML instead
    of JSON for printing results.
    """

    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'fancyyaml'

    def v2_runner_on_ok(self, result):
      if result._task.action in ['package', 'zypper', 'zypper_repository']:
          del result._result['stdout']
      super(CallbackModule, self).v2_runner_on_ok(result)
