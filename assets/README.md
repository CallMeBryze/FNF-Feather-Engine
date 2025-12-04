# Instructions
Assets are seperated into seperate libraries. Most libraries cache all assets upon loaded, but default keeps assets out of cache.
Although, that's an over-simplification.

## Libraries
Libraries help prevent stutters mid-game, or when transitioning between states. To add a library, you must define it in your `Project.xml` first.
You can also override an asset in shared/default by giving it the same file name and path as a file in shared/default.

You are able to load assets outside of the currently loaded library, however I do not recommend doing so.

### Default
Smaller assets that don't influence load times should go here. These assets may be cached, but will be dropped from the cache when not in use.

### Shared
These assets are always cached. They will always be stored in memory, ready to go at a moments notice.

### Custom (ex: `week1`)
These assets will cached before moving to a state when necessary, and removed when a new library is to be loaded.