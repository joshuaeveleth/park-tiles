SELECT irma_wsd.poly_geom                                  AS poly_geom,
irma_wsd.point_geom                                  AS point_geom,
Coalesce(irma_wsd.poly_source, 'None') AS poly_source,
       Coalesce(irma_wsd.unit_code, park_attributes.alpha) AS unit_code,
       park_attributes.pointtopol,
       park_attributes.designation,
       park_attributes.name,
       park_attributes.display_name,
       park_attributes.display_designation,
       park_attributes.display_concatenated,
       park_attributes.display_state,
       park_attributes.display_blurb,
       park_attributes.display_url,
       park_attributes.display_address,
       park_attributes.display_phone,
       park_attributes.display_climate
FROM   park_attributes full outer join (
       SELECT
         Coalesce(poly.unit_code, point.unit_code) as unit_code,
         poly.source as poly_source,
         poly.geom as poly_geom,
         point.wkb_geometry as point_geom
       FROM
         wsd_points AS point FULL OUTER JOIN
       (SELECT
                       Coalesce(wsd.unit_code, irma.unit_code)       AS unit_code,
                        CASE 
                          WHEN (wsd.wkb_geometry IS NOT NULL) then 'WSD_Parks'
                          WHEN (irma.wkb_geometry IS NOT NULL) then 'IRMA'
                          ELSE 'Unknown'
                        END as source,
                       Coalesce(wsd.wkb_geometry, irma.wkb_geometry) AS geom
                        FROM   (SELECT irma_nps_boundaries.unit_code,
       St_collect(Array_agg(irma_nps_boundaries.wkb_geometry)) AS
       wkb_geometry
       FROM   irma_nps_boundaries
       GROUP  BY irma_nps_boundaries.unit_code) AS irma
       full outer join (SELECT wsd_polys.unit_code,
                       St_collect(Array_agg(wsd_polys.wkb_geometry)) AS
       wkb_geometry
                FROM   wsd_polys
                GROUP  BY wsd_polys.unit_code) AS wsd
            ON irma.unit_code = wsd.unit_code) AS poly ON point.unit_code = poly.unit_code) AS irma_wsd
            ON park_attributes.alpha = irma_wsd.unit_code
       WHERE
         display_designation != 'National Historic Trail' AND
         display_designation != 'National Scenic Trail' AND
         unit_code != 'SEKI';
