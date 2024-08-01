#!/bin/zsh

table_id='d13d9ca98add4d30b2971de2c2e0e214'
name=''
project_type='Bug'
jira_id=''
duration='Limited Duration'
project_status='In progress'
branch=''
current=false
help=false

# Parse arguments
for (( i = 1; i <= $#; i++ )); do
    case "${(P)i}" in
        --current)
            current=true
            ;;
        --name)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                name="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --name requires a value."
                exit 1
            fi
            ;;
        --jira-id)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                jira_id="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --jira-id requires a value."
                exit 1
            fi
            ;;
        --branch)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                branch="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --branch requires a value."
                exit 1
            fi
            ;;
        --type)
            # Check if the next argument exists
            if [[ $((i + 1)) -le $# ]]; then
                project_type_argument="${(P)$((i + 1))}"
                ((i++))  # Skip the next argument since it's the value for --branch
            else
                echo "Error: --branch requires a value."
                exit 1
            fi
            ;;
        --help)
            help=true
            ;;
        *)
            echo "Unknown option: ${(P)i}"
            exit 1
            ;;
    esac
done

if [[ $help == true ]]; then
    echo "Usage: create-notion-project [options]"
    echo "Options:"
    echo "  --name <name>       The name of the project."
    echo "  --jira-id <id>      The Jira ID of the project."
    echo "  --branch <branch>   The branch name of the project."
    echo "  --current           Set the project as the current project."
    echo "  --type <type>       The type of the project. Valid values are: story, bug, general project, general area, code review, training subject."
    echo "  --help              Display this help message."
    exit 0
fi

# If project type argument has been set, map it to the correct value
if [ -n "${project_type_argument}" ]; then
    case "${project_type_argument}" in
        story)
            project_type='Story'
            ;;
        bug)
            project_type='Bug'
            ;;
        "general project")
            project_type='General Project'
            ;;
        "general area")
            project_type='General Area'
            ;;
        "code review")
            project_type='Code Review'
            ;;
        "training subject")
            project_type='Training Subject'
            ;;
        *)
            echo "Error: Invalid value for --type. Valid values are: story, bug, general project, general area, code review, training subject."
            exit 1
            ;;
    esac
fi

data='
  {
    "parent": { "database_id": "'"${table_id}"'"},
    "properties": {
      "Name": {
        "title": [
          {
            "text": {
              "content": "'"${name}"'"
            }
          }
        ]
      },
      "Branch": {
        "rich_text": [
          {
            "text": {
              "content": "'"${branch}"'"
            }
          }
        ]
      },
      "Jira ID": {
        "rich_text": [
          {
            "text": {
              "content": "'"${jira_id}"'"
            }
          }
        ]
      },
      "Type": {
        "select": {
          "name": "'"${project_type}"'"
        }
      },
      "Status": {
        "status": {
          "name": "'"${project_status}"'"
        }
      },
      "Duration": {
        "select": {
          "name": "'"${duration}"'"
        }
      },
      "Current?": {
        "checkbox": '${current}'
      }
    }
  }'

curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  --data $data  
