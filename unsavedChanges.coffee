# Prompt an user before he tries to leave the page (change Angular location or close the browser) and has unsaved changes
# Current service $route dependent and it will check the $scope of current route (it should match passed $scope) before attach listeners
#
# Usage: unsavedChanges.fnListen($scope, mListenableObject)
# Usage: unsavedChanges.fnRemoveListener()
#
# @author Umbrella-web <http://umbrella-web.com>
mosUnsavedChanges = angular.module 'unsavedChanges', []

mosUnsavedChanges.service 'unsavedChanges', ['$rootScope', '$window', '$route', ($rootScope, $window, $route)->
    MESSAGE = "Are you sure you don't want to save changes?"

    # It will contain listener for $locationChangeStart of $rootScope
    fnLocationListener = null

    @fnListen = ($scope, mListenableObject)->
        # If scope of current route isn't qual to listenable scope,
        # it means that user quickly switched the location and current controller finished loading before prev
        # and we no need to do anything in this case
        if $scope.$id isnt $route.current.scope.$id
            return

        # Remove old listeners
        @fnRemoveListener()

        # Hash of object when we started listening
        sInitialHash = fnHash mListenableObject

        # Location listener. If user tries to change location using Angular he will prompted
        fnLocationListener = $rootScope.$on '$locationChangeStart', (oEvent) =>

            # Hash of object before user tries to leave
            sFinalHash = fnHash mListenableObject

            # Compare initial hash of object and final hash. If these hashes doesn't match prompt a user
            if sFinalHash isnt sInitialHash and not confirm MESSAGE
                return oEvent.preventDefault() 
            else
                # Remove listeners if user leave the page
                @fnRemoveListener()

        # Window listener. If user tries to close tab/browser he will be prompted
        # http://habrahabr.ru/post/141793/
        $window.onbeforeunload = (evt)=>
            # Hash of object before user tries to leave
            sFinalHash = fnHash mListenableObject

            # Compare initial hash of object and final hash. If these hashes doesn't match prompt a user
            if sFinalHash isnt sInitialHash
                if typeof evt is "undefined" then evt = window.event
                if evt? then evt.returnValue = MESSAGE
                MESSAGE

        # Remove all listeners on scope destroy
        $scope.$on '$destroy', ()=>
            @fnRemoveListener()

    # Remove listener
    @fnRemoveListener = ()->
        fnLocationListener() if fnLocationListener?
        $window.onbeforeunload = null

    # Create a hash of object/string ... any var
    # I guess we can use another way to create an object hash, maybe md5 of JSON?
    fnHash = (something)->
        angular.toJson something

    return
]

