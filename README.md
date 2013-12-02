Angular-unsavedChanges
======================

Detect unsaved changes and alert user when he tries to leave the page without saving these changes

Usage
--------

1. include the script tag of this module

        <script src="unsavedChanges.js"></script>

2. Register the `unsavedChanges` module in your application

        angular.module('app', ['unsavedChanges']);

3. Attach a listener and pass the two arguments: current `$scope` and object which changes the service should listen

        unsavedChanges.fnListen($scope, $scope.myObject);

4. To reattach listener, for example after saving the changes by user, use the same method.
    
        $scope.myResource.$update(function(){
            unsavedChanges.fnListen($scope, $scope.myResource);
        })    

5. To remove all listeners, just call the `unsavedChanges.fnRemoveListener()` method. It's useful when you want to redirect user after deleting the object, for example.
        
        $scope.myResource.$delete(function(){
            unsavedChanges.fnRemoveListener();
        })
