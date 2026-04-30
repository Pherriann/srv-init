# Ansible Opencode Version

--- 
name: ansible-opencode-version
description: Use when implementing opencode features in Ansible workflows, ensuring compatibility with Ansible's task-driven execution and playbook-based automation.

# Overview
Ansible Opencode version for integrating OpenCode capabilities into Ansible workflows. Focuses on task automation, playbook execution, and dynamic code generation within Ansible environments.

## Core Principles
- **Task-Driven Execution:** Align with Ansible's task-oriented architecture.
- **Playbook Integration:** Ensure compatibility with YAML-based playbooks.
- **Dynamic Code Generation:** Support runtime code modifications via Jinja2 templates.
- **Idempotency:** Design changes to be idempotent for safe retries.

## When to Use
Use this skill when:
- Implementing OpenCode features in Ansible tasks.
- Integrating dynamic workflows with Ansible playbooks.
- Automating code generation and execution within Ansible environments.

### Key Symptoms
- Tasks fail due to missing Ansible task structure.
- Playbook execution errors related to Jinja2 templating.
- Dynamic code generation conflicts with static Ansible tasks.

## Architecture
This version ensures seamless integration between OpenCode's logic and Ansible's workflows by:
1. **Task Decomposition:** Breaking down complex OpenCode tasks into manageable Ansible tasks.
2. **Playbook Integration:** Structuring tasks within playbooks for execution.
3. **Dynamic Code Handling:** Using Jinja2 to generate code dynamically during task execution.
4. **Idempotency Checks:** Validating changes before applying them to avoid unintended side effects.

## Quick Reference
| Task Type          | Ansible Integration Approach                     |
|--------------------|-----------------------------------------------|
| Code Generation    | Use `template` module with Jinja2            |
| Dynamic Execution  | Execute tasks via `shell` or `command` modules |
| Idempotency Check  | Validate changes before applying             |

## Implementation
### Task Structure for Ansible Playbooks
```yaml
- name: Implement OpenCode feature in Ansible
  hosts: localhost
  tasks:
    - name: Generate dynamic code snippet
      ansible.builtin.template:
        src: templates/code_snippet.j2
        dest: /tmp/dynamic_code.py
    - name: Execute generated code dynamically
      ansible.builtin.command: python3 /tmp/dynamic_code.py
      register: execution_result
    - name: Validate execution result
      ansible.builtin.assert:
        that: execution_result.stdout is defined
        fail_msg: "Code execution failed"
```

### Example Playbook (`deploy_opencode.yml`)
```yaml
- hosts: localhost
  tasks:
    - name: Ensure OpenCode directory exists
      ansible.builtin.file:
        path: /tmp/opencode
        state: directory
    - name: Deploy Opencode feature dynamically
      block:
        - name: Generate and apply code changes
          ansible.builtin.include_tasks: tasks/deploy_feature.yml
        - name: Validate deployment
          ansible.builtin.assert:
            that: "Feature deployed successfully"
```

## Common Mistakes
- **Missing Jinja2 Support:** Forgetting to use `ansible.builtin.template` for dynamic code.
  **Fix:** Always include Jinja2 templates when generating dynamic code.

- **Non-Idempotent Changes:** Modifying files without checking if they already exist or match expected content.
  **Fix:** Use `ansible.builtin.stat` to check file existence and `ansible.builtin.copy` with `force: no` for idempotency.

- **Task Execution Errors:** Not handling dynamic code execution failures gracefully.
  **Fix:** Wrap execution in `register` and validate results using `assert`.

## Real-World Impact
This version ensures that OpenCode features can be seamlessly integrated into Ansible workflows, enabling:
- Dynamic task automation with minimal manual intervention.
- Safe and repeatable deployments via idempotent operations.
- Flexible execution environments supporting both static and dynamic code generation.

---