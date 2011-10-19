Feature: Push

  Background:
    Given an orb named "test"
    And a repository named "repository"

  Scenario: Push an orb to a local repository
    When I successfully run `orb push test -s test`
    Then a file named "repository/index.xml" should exist
    And a file named "repository/orbs/test-0.0.1.orb" should exist