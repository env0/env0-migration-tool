## Description: 

This guide can serve as a reference to troubleshoot and address any issues encountered during the state migration process.

1. **Required token could not be found**
    - If you encounter an error stating "Required token could not be found," follow these steps:
        - Generate a token by running: 
            ```
            echo -n $ENV0_API_KEY:$ENV0_API_SECRET | base64
            ```
        - Log in to the env0 backend using: 
            ```
            terraform login backend.api.env0.com
            ```
        - Enter the previously generated base64 token directly into terminal when prompted
            - `NOTE:` it might open a browser with the env0 page to add Personal API Keys. Just ignore the page as you just added it with the terminal
        - Remove all generated workspace files
        - Re-run the migration script

2. **Terraform Version Mismatch:**
   - If you receive a Terraform version mismatch message:
     1. Install tfenv using: 
        ```
        brew install tfenv
        ```
     2. Use version any version below `1.6.0` (e.g. `1.5.3`)
        ```
        tfenv use 1.5.3
        ```
     3. If conflicts arise between Terraform installations
        - uninstall and reinstall Terraform using brew
        - Re-export all variables if needed
     4. Re-run the migration script

3. **Error Acquiring State Lock:**
   - If you encounter an "Error acquiring the state lock":
     - Copy the lock ID from the message
     - Go to the env0 platform 
        - Project environment -> kebab menu -> Run a task:
            ```
            terraform force-unlock -force <LOCK_ID>
            ```
     - If unsuccessful, navigate to the workspace directory and run:        
        ```
        terraform force-unlock -force <LOCK_ID>
        ```
     - If the issue persists, use `tfenv` with any version below `1.6.0` 
        - Run: 
            ```
            terraform force-unlock -force LOCK_ID
            ```
        - Confirm the message "Terraform state has been unlocked."
        - Remove the temporary workspaces folder.
        - Finally, run the migrate-workspaces script.
