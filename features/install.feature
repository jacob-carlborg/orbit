Feature: Install

  Background:
    Given the environment variable "ORB_HOME" is "orbit"
    And a repository named "repository"

  Scenario: Install an orb from a local repository
    Given an orb named "test" in the repository "repository"
    When I successfully run `orb install test -s repository`
    Then a file named "orbit/orbs/test-0.0.1/bin/test" should exist