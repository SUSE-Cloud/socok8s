==============================
Ansible tips
==============================


There are several variables for extra debugging from the Ansible playbooks as
shown in https://docs.ansible.com/ansible/latest/reference_appendices/config.html.

Some examples:

.. code-block:: console

    export ANSIBLE_VERBOSITY=3
    export ANSIBLE_STDOUT_CALLBACK=debug

Both of these environment variables will enable verbosity and debug for all the
playbooks being run.

You can enable the debugger for failed tasks as shown in
https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html.

.. code-block:: console

    export ANSIBLE_ENABLE_TASK_DEBUGGER=True


This launches the debugger when a task fails so you can examine the task, vars,
and retry the task. Check the Ansible docs link for all available options.

The debug task allows you to print to stdout while playbooks are executed
without necessarily halting the playbook. Detailed information is available at:
https://docs.ansible.com/ansible/latest/modules/debug_module.html


.. note ::
    These settings can be also set in your ~/.ansible.cfg file
