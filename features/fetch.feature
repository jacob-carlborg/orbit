Feature: Fetch

  Background:
    Given a repository named "repository"

  Scenario: Fetch an orb from a local repository
    Given an orb named "test" in the repository "repository"
    When I successfully run `orb fetch test -s repository`
    Then a file named "test-0.0.1.orb" should exist