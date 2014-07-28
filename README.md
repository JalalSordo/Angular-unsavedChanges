Angular-unsavedChanges
======================

[![SensioLabsInsight](https://insight.sensiolabs.com/projects/3e29e5ef-977a-4c86-908a-3557aa6193c6/big.png)](https://insight.sensiolabs.com/projects/3e29e5ef-977a-4c86-908a-3557aa6193c6)

Detect unsaved changes and alert user when he tries to leave the page without saving these changes

Usage
--------

1. include the script tag of this module

        <script src="unsavedChanges.js"></script>

2. Register the `unsavedChanges` module in your application

        angular.module('app', ['unsavedChanges']);

3. Attach a listener and pass the three arguments: current `$scope`, slug of the listener (any random unique name, it's necessary because you can attach severl listeners at once) and object which changes the service should listen
		
		unsavedChanges.fnAttachListener($scope, 'products-changes', $scope.oPlChangeLog.oValues);

4. To reattach listener, for example after saving the changes by user, use the same method.
    
        unsavedChanges.fnReAttachListener('products-changes');

5. To detach one of the listeners.

		unsavedChanges.fnDetachListener('products-changes');

6. To remove all listeners, just call the `unsavedChanges.fnDetachListeners()` method. It's useful when you want to redirect user after deleting the object, for example.
        
        unsavedChanges.fnDetachListeners();

7. To check if the object you listen was changed:

		unsavedChanges.fnHasChanges('products-changes');