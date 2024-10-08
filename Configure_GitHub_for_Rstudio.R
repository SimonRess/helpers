#INFOS about GITHUB Personal Access Tokens
  https://happygitwithr.com/https-pat#store-pat

#--------------------------------#
# Adding credentials manually ####
#--------------------------------#

# In R Studio Terminal 
# - Navigate into  ".ssh" 
`cd <...>/.ssh`
#check existing files
`ls -la`
# - if not already existing add file ".git-credentials" 
touch .git-credentials
# - add content (PAT = Personal access tokens from https://github.com/settings/tokens): https://PersonalAccessToken:<PAT>@github.com
vim .git-credentials
# check content of .git-credentials file
`cat .git-credentials`

#------------------------------------------------#
# Adding credentials with {gitcreds} package  ####
#------------------------------------------------#
#Leads to the same result als manual adding of git credentials

#put the PAT into the Git credential store
  gitcreds::gitcreds_set()

#check .git-credentials file
  file.edit("~/.git-credentials")

#----------------------------#
# Using package {usethis] ####
#----------------------------#

# see original: https://gist.github.com/Z3tt/3dab3535007acf108391649766409421

#### 1. Sign up at GitHub.com ################################################

## If you do not have a GitHub account, sign up here:
## https://github.com/join

# ----------------------------------------------------------------------------

#### 2. Install git ##########################################################

## If you do not have git installed, please do so: 
## Windows ->  https://git-scm.com/download/win
## Mac     ->  https://git-scm.com/download/mac
## Linux   ->  https://git-scm.com/download/linux
##             or: $ sudo dnf install git-all

# ----------------------------------------------------------------------------

### 3. Configure git with Rstudio ############################################

## set your user name and email:
usethis::use_git_config(user.name = "YourName", user.email = "your@mail.com")

## create a personal access token for authentication:
usethis::create_github_token() 
## in case usethis version < 2.0.0: usethis::browse_github_token() (or even better: update usethis!)

## Note for Linux users:
## credentials::set_github_pat() (in line 34) might store your PAT in a memory cache that
## expires after 15 minutes or when the computer is rebooted. You thus may wish to do 
## extend the cache timeout to match the PAT validity period:
usethis::use_git_config(helper="cache --timeout=2600000") #> cache timeout ~30 days

## set personal access token:
credentials::set_github_pat("YourPAT")

## or store it manually in '.Renviron':
usethis::edit_r_environ()
## store your personal access token in the file that opens in your editor with:
## GITHUB_PAT=xxxyyyzzz
## and make sure '.Renviron' ends with a newline

# ----------------------------------------------------------------------------

#### 4. Restart R! ###########################################################

# ----------------------------------------------------------------------------

#### 5. Verify settings ######################################################

usethis::git_sitrep()

#another way to check settings
gitcreds::gitcreds_get("https://github.com", use_cache=F)

## Your username and email should be stated correctly in the output. 
## Also, the report shoud cotain something like:
## 'Personal access token: '<found in env var>''

## If you are still having troubles, read the output carefully.
## It might be that the PAT is still not updated in your `.Renviron` file.
## Call `usethis::edit_r_environ()` to update that file manually.

# ----------------------------------------------------------------------------

## THAT'S IT!
