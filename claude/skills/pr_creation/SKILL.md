---
name: pr_creation
description: Generates PR titles and descriptions.
---

Write a PR title and description leveraging the @.github/PULL_REQUEST_TEMPLATE.md if available. If the template is not available
then the structure should follow:

## Structure

### PR title

<type>: <short description>

### PR description

<description>
    ## Description

    <!-- What does this PR do? -->

    ## Type of Change

    - [ ] Bug fix
    - [ ] New feature
    - [ ] Breaking change
    - [ ] Documentation update

    ## Testing

    - [ ] Tests pass locally
    - [ ] Added/updated tests for changes

    ## Checklist

    - [ ] Code follows style guidelines (Black, isort)
    - [ ] Type hints added
    - [ ] Updated documentation
    - [ ] Updated changelog files
</description>
