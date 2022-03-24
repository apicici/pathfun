Navigation
================
.. include:: global.rst

|badge complete|

A class to handle pathfinding on a region specified by a list of polygonal meshes.

**Example:**

.. code-block::

    local pathfun = require "pathfun"
    
    -- In this example the first polygon map describes two disjoint polygons, while the 
    -- second one is a (currently hidden) bridge between them.
    local polygon_maps = {
        {
            {{520,441},{456,429},{454,342},{658,370},{666,436}},
            {{520,441},{666,436},{549,498}},
            {{822,391},{880,372},{868,446},{747,431}},
            {{822,391},{747,431},{754,360},{796,346}}
        },
        {
            {{747,431},{666,436},{658,370},{754,360}},
            hidden = true,
            name = "bridge"
        }
    }
    
    local navigation = pathfun.Navigation(polygon_maps)

    -- optional, only needed if to force initialisation right now
    navigation:initialize() 
    
    -- returns false since the point is in the hidden polygon map
    navigation:is_point_inside(706, 401)

    -- returns {{564,467}, {665,436}} since the bridge is hidden
    navigation:shortest_path(564, 467, 856, 437)

    -- make the bridge visible
    navigation:toggle_visibility("bridge")

    -- now returns true
    navigation:is_point_inside(706, 401)

    -- returns {{564,467}, {665,436}, {747, 431}, {856, 437}}
    navigation:shortest_path(564, 467, 856, 437)

    
Initialisation
--------------

.. function:: pathfun.Navigation(pmaps)

    Creates a new :class:`Navigation` object.

    :param table pmaps: a table representing a list of polygon maps. Each polygon map is itself a table 
        of *convex* polygons (represented by a list of pairs of coordinates), with optional fields ``name`` 
        (a string) and ``hidden`` (a boolean).
        
 
    :returns: A :class:`Navigation` object.


    .. note::

        - Separate polygon maps can be used to dynamically change the navigation area by hiding/unhiding them to create/remove an obstacle.
          If this feature is not needed a single polygon map is enough to describe the navigation area, even if it consists
          of disjoint pieces and/or has holes.

        - Only named polygon maps can by hidden. The ``hidden`` field is ignored if a name is not provided.

        - A the region described by a single polygon map is obtained by taking the union of the convex polygons it contains.
          Note however that the library assumes that the polygons provide a convex decomposition of the area, so there should
          be no overlaps. The intersection between two polygons can only be:

            + empty
            + an edge shared by the two polygons (in which case the polygons are considered connected)
            + a vertex point
            

        - The same conditions as above apply to the overlap of multiple polygon maps. Moreover, the libary expects all vertices
          to be external vertices. If joining two polygon maps makes one or more of their shared vertices internal the pathfinding
          algorithm will not behave as expected.


Methods
--------------

.. class:: Navigation

    .. method:: initialize()
        
        Populates the information about the connections between the various polygons in the polygon maps.
        This method is called automatically the first time the ``is_point_inside``, ``closest_boundary_point``, or
        ``shortest_path`` methods are called, so it's not necessary to call it explicitly. You can call it to
        force the initialisation to happen at a specified time instead.
        
    .. method:: toggle_visibility(name)

        Toggles the visibility status of the polygon map with name ``name``.

        :param string name: the name of the polygon map.

    .. method:: set_visibility(name, value)

        Sets the visibility status of the polygon map with name ``name`` to ``value``.

        :param string name: the name of the polygon map.
        :param boolean value: the new visibility value.
        
    .. method:: is_point_inside(x, y)

        Checks whether the point ``(x, y)`` is inside the visible navigation area.
        
        :param numbers x, y: coordinates of the point. They must be integers to ensure the result is correct.
        :return type: boolean
        
    .. method:: closest_boundary_point(x, y)

        Finds the point on the boundary of the visible navigation area which is closest to a given point.
        
        :param numbers x, y: coordinates of the point.
        :return: the coordinates of the closest boundary point, as two separate outputs.

    .. method:: shortest_path(x1, y1, x2, y2)
        
        Finds the shortest path between ``(x1, y1)`` and ``(x2, y2)`` within the visible navigation area.
        
        :param numbers x1, y1: coordinates of the starting point. Automatically rounded to integer coordinates.
        :param numbers x2, y2: coordinates of the target point. Automatically rounded to integer coordinates.

        :return: A table of coordinates of the form ``{x, y}``, representing the vertices of the piece-wise path. \
            The (rounded) starting and target point are included in the list. 

        .. note::

            - If the starting point is outside of the visible navigation area it is replaced
              with the closest boundary point.
            - If the target point is unreachable from the starting point (either because it is outside of the
              navigation area or because it is in a disconnected region) it is replaced with the closest boundary point
              *whithin the region connected to the starting point*, i.e. the reachable point which is closest to the target point.
