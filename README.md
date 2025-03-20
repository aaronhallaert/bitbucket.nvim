# 🪣 Bitbucket.nvim

⚠️ Early development ⚠️

A nvim client for Bitbucket, intended to inspect pullrequests. 

Heavily inspired by [octo.nvim](https://github.com/pwntester/octo.nvim)

## Setup 

1. Create an app password [here](https://bitbucket.org/account/settings/app-passwords/).
2. Execute `:Bitbucket auth` in nvim 
3. Fill in the prompts


## Commands

`:Bitbucket`

| Ex command | subcommand | context     | action                                                                                                 |
| ---        | ---        | ---         | ---                                                                                                    |
| pull       | mine       |             | open picker for all my pullrequests in the current repo                                                |
|            | reviewing  |             | open picker for all pullrequests marked as reviewer in the current repo                                |
|            | comment    | in diffview | create a pending comment                                                                               |
|            | approve    |             | approve the last opened pullrequest (note: this won't finalize pending comments, it will only approve) |
| auth       |            |             | authenticate with username and APP_PASSWORD                                                            |

## Keymaps

| mode   | keys       | action             | context                    |
| ------ | ------     | --------           | ---------                  |
| normal | go         | open br in browser | bitbucket buffer           |
| normal | gc         | checkout branch    | bitbucket buffer           |
| normal | gd         | open diff          | bitbucket buffer           |
| normal | gf         | go to file         | bitbucket buffer - comment |
| normal | <leader>rt | resolve thread     | bitbucket buffer - comment |
| normal | <leader>ot | reopen thread      | bitbucket buffer - comment |

## Dependencies

* [diffview.nvim](https://github.com/sindrets/diffview.nvim)
