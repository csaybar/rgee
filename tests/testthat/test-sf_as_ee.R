context("rgee: sf_as_ee test")
skip_if_no_pypkg()
# -------------------------------------------------------------------------

filename <- system.file("external/lux.shp", package = "raster")
nc <- system.file("shape/nc.shp", package = "sf")

test_that("sf_as_ee.sf", {
  p <- sf::read_sf(filename) %>%
    sf::st_as_sf()
  ee_p <- sf_as_ee(p)
  expect_is(ee_p, "ee.featurecollection.FeatureCollection")
})

test_that("sf_as_ee.sfc", {
  p <- sf::read_sf(filename) %>%
    sf::st_as_sf() %>%
    sf::st_geometry()
  ee_p <- sf_as_ee(p)
  expect_is(ee_p$geometry(), "ee.geometry.Geometry")
})

test_that("sf_as_ee.sfg", {
  p <- sf::read_sf(filename) %>%
    sf::st_geometry() %>%
    "[["(1) %>%
    sf_as_ee()
  expect_is(p, "ee.geometry.Geometry")
})

test_that("sf_as_ee - getInfo_to_asset", {
  remove_id <- sprintf("%s/sf_as_ee_test", ee_get_assethome())
  p <- sf::read_sf(filename) %>%
    sf::st_as_sf() %>%
    sf::st_geometry() %>%
    "[["(1) %>%
    sf_as_ee(
      overwrite = TRUE,
      assetId = remove_id,
      via = "getInfo_to_asset"
    )
   expect_is(p$geometry(), "ee.geometry.Geometry")
})

test_that("sf_as_ee - gcs_to_asset", {
  skip_if_no_credentials()
  remove_id <- sprintf("%s/sf_as_ee_test", ee_get_assethome())
  p <- sf::read_sf(filename) %>%
    sf::st_as_sf() %>%
    sf::st_geometry() %>%
    "[["(1) %>%
    sf_as_ee(
      assetId = remove_id,
      overwrite = TRUE,
      bucket = gcs_bucket_f(),
      via = "gcs_to_asset")
  expect_is(p$geometry(), "ee.geometry.Geometry")
})

test_that("sf_as_ee - single", {
  remove_id <- sprintf("%s/sf_as_ee_test", ee_get_assethome())
  p_sf <- sf::read_sf(filename)[1,]
  p_sfc <- sf::read_sf(filename)[1,]$geometry
  p_sfg <- sf::read_sf(filename)[1,]$geometry[[1]]
  expect_is(sf_as_ee(p_sf)$geometry(), "ee.geometry.Geometry")
  expect_is(sf_as_ee(p_sfc), "ee.geometry.Geometry")
  expect_is(sf_as_ee(p_sfg), "ee.geometry.Geometry")
})


test_that("ERROR 01", {
  expect_error(
      sf::read_sf(filename) %>%
      sf::st_as_sf() %>%
      sf::st_geometry() %>%
      sf_as_ee(via = "cesar")
  )
})

test_that("ERROR 02", {
  ss_ff <- sf::st_read(filename)
  sf::st_crs(ss_ff) <- NA
  expect_error(
    sf_as_ee(ss_ff, geodesic  = TRUE)
  )
})

test_that("ERROR 03", {
  ss_ff <- "other_class"
  expect_error(
    sf_as_ee(ss_ff)
  )
})

test_that("ERROR 04", {
  ss_ff <- "other_class"
  expect_error(
    sf_as_ee(ss_ff)
  )
})
