# Prompt a user before he tries to leave the page (change Angular location or close the browser) and has unsaved changes
# Current service $route dependent and it will check the $scope of current route (it should match passed $scope) before attach listeners
#
# It is possible to make not only one object as listenable.
#
# Usage: unsavedChanges.fnAttachListener($scope, sSlug, mListenableObject)
# Usage: unsavedChanges.fnDetachListener(sSlug)
# Usage: unsavedChanges.fnDetachListeners()
# Usage: unsavedChanges.fnTrigger(sSlug)
#
# @author Umbrella-web <http://umbrella-web.com>
mosUnsavedChanges = angular.module 'mosSvcs.unsavedChanges', []

mosUnsavedChanges.service 'unsavedChanges', ['$rootScope', '$window', '$route', ($rootScope, $window, $route)->
    MESSAGE = "Are you sure you don't want to save changes?"

    # Collection of listenable objects
    # Format of collection:
    ## %unique identify% : { oPristine: %prestine object%, oCurrent: %current object% }
    oListenableCollection = {}

    # It will contain listener for $locationChangeStart of $rootScope
    fnLocationListener = null

    # Adds object as listenable
    ## $scope - scope object of controller
    ## sSlug - unique slug to identify an object in listenable collection
    ## mListenableObject - an object to listen
    @fnAttachListener = ($scope, sSlug, mListenableObject) ->
        # If scope of current route isn't qual to listenable scope,
        # it means that user quickly switched the location and current controller finished loading before prev
        # and we no need to do anything in this case
        return if $route.current.scope && $scope.$id isnt $route.current.scope.$id

        # Set object as listenable
        oListenableCollection[sSlug] = {}
        oListenableCollection[sSlug].oPristine = angular.copy mListenableObject
        oListenableCollection[sSlug].oCurrent = mListenableObject

        # Do not add listeners if they are already set
        return if fnLocationListener?

        # Location listener. If user tries to change location using Angular he will prompted
        fnLocationListener = $rootScope.$on '$locationChangeStart', (oEvent) =>
            # Checkout each object in collection for unsaved changes
            for sSlug, oListenableObject of oListenableCollection 
                if @fnHasChanges(sSlug) is yes
                    
                    # Break the loop if location change is confirmed
                    break if confirm MESSAGE

                    # Do not change location if confirm is canceled
                    return oEvent.preventDefault()

            # Location change is confirmed or there are no changes
            @fnDetachListeners()

        # Window listener. If user tries to close tab/browser he will be prompted
        # http://habrahabr.ru/post/141793/
        $window.onbeforeunload = (oEvent) =>
            # Checkout each object in collection for unsaved changes
            for sSlug, oListenableObject of oListenableCollection 
                if @fnHasChanges(sSlug) is yes
                    if typeof oEvent is "undefined" then oEvent = $window.event
                    if oEvent? then oEvent.returnValue = MESSAGE
                    return MESSAGE

        # Remove listeners on scope destroy
        $scope.$on '$destroy', () =>
            @fnDetachListeners()

    # Detach object as listenable
    @fnDetachListener = (sSlug) ->
        # Prevent errors if parameter is not a string
        return if not angular.isString sSlug

        # Remove object from listenable collection
        delete oListenableCollection[sSlug] if oListenableCollection.hasOwnProperty sSlug

    # Detach all objects as listenable
    @fnDetachListeners = ->
        oListenableCollection = {}
        fnLocationListener() if fnLocationListener?
        fnLocationListener = null
        $window.onbeforeunload = null

    # Reattach listener with a current value of listenable object
    @fnReAttachListener = (sSlug)->
        oListenableCollection[sSlug].oPristine = angular.copy oListenableCollection[sSlug].oCurrent

    # Trigger the checking manually for list of slugs.
    # return false if user can leave, true otherwise
    @fnTrigger = (aSlugs...) ->
        bTotalChanges = false
        bTotalChanges = bTotalChanges or @fnHasChanges(sSlug) for sSlug in aSlugs

        bTotalChanges and not confirm MESSAGE

    # Check if we have unsaved changes for the specific slug
    @fnHasChanges = (sSlug)->
        # Return false if parameter is not a string or listenable object with this slug is not exists
        return false if (not angular.isString sSlug) or not oListenableCollection.hasOwnProperty sSlug

        not angular.equals(oListenableCollection[sSlug].oPristine, oListenableCollection[sSlug].oCurrent)

    return
]
