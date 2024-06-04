import requests
from requests.auth import HTTPBasicAuth
import base64

# Configuration
organization = 'YOUR_ORG'
project = 'YOUR_PROJECT'
pat = 'YOUR_PERSONAL_ACCESS_TOKEN'
template_content = '''
## Description
<!-- Please include a summary of the change and which issue is fixed. Please also include relevant motivation and context. -->
Fixes # (issue)

## Type of change
<!-- Please delete options that are not relevant. -->
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How Has This Been Tested?
<!-- Describe the tests that you ran to verify your changes. -->

## Checklist:
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests
- [ ] New and existing unit tests pass
- [ ] Any dependent changes have been merged and published in downstream modules
'''

# Encode PAT for HTTP Basic Auth
auth = HTTPBasicAuth('', pat)

# Get all repositories
repos_url = f'https://dev.azure.com/{organization}/{project}/_apis/git/repositories?api-version=6.0'
response = requests.get(repos_url, auth=auth)
repos = response.json()['value']

# Function to create or update pull_request_template.md
def upload_template(repo_id, template_content):
    template_path = 'pull_request_template.md'
    url = f'https://dev.azure.com/{organization}/{project}/_apis/git/repositories/{repo_id}/pushes?api-version=6.0'
    
    # Create the push object
    push_data = {
        "refUpdates": [{"name": "refs/heads/main", "oldObjectId": "0000000000000000000000000000000000000000"}],
        "commits": [{
            "comment": "Add pull request template",
            "changes": [{
                "changeType": "add",
                "item": {"path": template_path},
                "newContent": {
                    "content": template_content,
                    "contentType": "rawtext"
                }
            }]
        }]
    }

    # Push the template to the repository
    response = requests.post(url, json=push_data, auth=auth)
    if response.status_code == 200:
        print(f"Template uploaded to repo {repo_id}")
    else:
        print(f"Failed to upload template to repo {repo_id}: {response.json()}")

# Upload the template to each repository
for repo in repos:
    upload_template(repo['id'], template_content)
