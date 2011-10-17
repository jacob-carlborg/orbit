Feature: Build

  Background:
    Given I have an orbspec "test"

  Scenario: Building an orb with extension
    When I successfully run `orb build test.orbspec`
    Then a file named "test.orb" should exist
    
  Scenario: Building an orb without extension
    When I successfully run `orb build test`
    Then a file named "test.orb" should exist