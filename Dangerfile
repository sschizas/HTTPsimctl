declared_trivial = (github.pr_title + github.pr_body).include?("#trivial")

# PR is a work in progress and shouldn't be merged yet
warn "PR is classed as Work in Progress" if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn "Big PR, consider splitting into smaller" if git.lines_of_code > 500

# Mainly to encourage writing up some reasoning about the PR, rather than
# just leaving a title
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

# If these are all empty something has gone wrong, better to raise it in a comment
if git.modified_files.empty? && git.added_files.empty? && git.deleted_files.empty?
  fail "This PR has no changes at all, this is likely an issue during development."
end

if !git.modified_files.include?("CHANGELOG.md") && !declared_trivial && github.branch_for_base == "main"
  fail("Please include a CHANGELOG entry.", sticky: false)
end

# Lint commits
commit_lint.check

# Check changelog format
changelog.format = :keep_a_changelog
changelog.check!