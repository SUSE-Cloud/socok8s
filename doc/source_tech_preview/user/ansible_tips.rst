==============================
Ansible tips
==============================


There is several variables that you can use to get extra debugging from the ansible playbooks as shown in https://docs.ansible.com/ansible/latest/reference_appendices/config.html

Some examples:

.. code-block:: console

    export ANSIBLE_VERBOSITY=3
    export ANSIBLE_STDOUT_CALLBACK=debug

Both of this environment variables will enable a lot of verbosity and debug for all the playbooks being run


You can also enable the debugger for failed tasks as shown in https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html

.. code-block:: console

    export ANSIBLE_ENABLE_TASK_DEBUGGER=True


This will drop you into the debugger when a task fails so you can examine the task, vars, retry it and so on. Make sure to check the ansible docs linked for all available options


Other notable helpers are the debug task which will allow you to print to stdout while the playbooks are executed: https://docs.ansible.com/ansible/latest/modules/debug_module.html


.. note ::
    All this settings can be also set in your ~/.ansible.cfg file
