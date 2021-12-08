Feature: Behat scenarios for custom modifications and extensions

  Background:
    Given a file named "features/bootstrap/FirstContext.php" with:
          """
          <?php

          class FirstContext implements \Behat\Behat\Context\Context
          {
              /** @Given I have some pre-conditions */
              public function simpleGivenStep() { }

              /** @When I do some actions */
              public function simpleWhenStep() { }

              /** @Then there should be some consequences */
              public function simpleThenStep() { }

               /** @Then I make an assertion that fails */
              public function failingAssertion() {
                throw new Exception("Fake exception");
              }
          }
          """

  Scenario: Parallel worker should work with multiple scenarios on feature file (lineFilters() should run last)
    Given a file named "behat.yml" with:
          """
          default:
            extensions:
              Medology\Behat\ParallelWorker\Extension: ~
            formatters:
              pretty:
                expand: true
            suites:
              first:
                contexts: [ FirstContext ]
          """
      And a file named "features/some.feature" with:
          """
          Feature: Some story

            Scenario: This is a decoy scenario
              Given I have some pre-conditions

            Scenario: This is the scenarios needs to be checked
              Given I have some pre-conditions
               When I do some actions
               Then there should be some consequences
          """
     When I run "behat --total-workers='2' features/some.feature:6"
     Then it should pass
