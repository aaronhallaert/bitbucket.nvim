describe("api", function()
    describe("parses next page", function()
        local next =
            "https://api.bitbucket.org/2.0/repositories/tlv-conference/plixus-apps/pullrequests/1465/comments?fields=size%2Cnext%2Cvalues.%2A%2Cvalues.resolution.%2A&page=2"

        local page = next:match(".*page=(%d*)$")

        assert.are.same(page, "2")
    end)
end)
