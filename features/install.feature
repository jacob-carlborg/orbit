Feature: Install

  Background:
    Given a repository named "repository"

  Scenario: Install an orb from a local repository
    Given an orb named "test" in the repository "repository"
    And a directory named "orbs"
    When I successfully run `orb install test -s repository`
    Then a file named "orbs/orbit-0.0.1/bin/orb" should exist