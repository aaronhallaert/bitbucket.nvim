local Env = require("bitbucket.utils.env")

describe("environment", function()
    describe("parse_remote_", function()
        it("parses the remote correctly", function()
            local remote = "git@bitbucket.com:workspace/repo.git"
            local workspace, repo = Env:_parse_remote(remote)
            assert.equals(workspace, "workspace")
            assert.equals(repo, "repo")
        end)

        it("remote with dashes", function()
            local remote =
                "git@bitbucket.com:workspace-with-dashes/repo-with-dashes.git"
            local workspace, repo = Env:_parse_remote(remote)
            assert.equals(workspace, "workspace-with-dashes")
            assert.equals(repo, "repo-with-dashes")
        end)

        it("remote with git in name", function()
            local remote = "git@bitbucket.com:workspace-git/digital-repo.git"
            local workspace, repo = Env:_parse_remote(remote)
            assert.equals(workspace, "workspace-git")
            assert.equals(repo, "digital-repo")
        end)
    end)
end)
