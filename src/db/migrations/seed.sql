with
  blender as (
    select
      org.id as org,
      lasse.id as lasse,
      maria.id as maria,
      johannes.id as johannes,
      jorgen.id as jorgen,
      jonas.id as jonas,
      dansdata.add_organization_member (org.id, lasse.id, 'Kapellmästare & sång'::text),
      dansdata.add_organization_member (org.id, maria.id, 'Sångerska'::text),
      dansdata.add_organization_member (org.id, johannes.id, 'Keyboard'::text),
      dansdata.add_organization_member (org.id, jorgen.id, 'Elbas'::text),
      dansdata.add_organization_member (org.id, jonas.id, 'Gitarr'::text)
    from
      dansdata.create_organization ('Blender') org,
      dansdata.create_individual ('Lasse Lundberg') lasse,
      dansdata.create_individual ('Maria Persson') maria,
      dansdata.create_individual ('Johannes Winroth') johannes,
      dansdata.create_individual ('Jörgen Sandström') jorgen,
      dansdata.create_individual ('Jonas Hedlund') jonas
  ),
  casanovas as (
    select
      org.id as org,
      jimmy.id as jimmy,
      henrik.id as henrik,
      simon.id as simon,
      stefan.id as stefan,
      victor.id as victor,
      dansdata.add_organization_member (org.id, jimmy.id, 'Gitarr och sång'::text),
      dansdata.add_organization_member (org.id, henrik.id, 'Sång och Keyboard'::text),
      dansdata.add_organization_member (org.id, simon.id, 'Trummor'::text),
      dansdata.add_organization_member (org.id, stefan.id, 'Bas och sång'::text),
      dansdata.add_organization_member (org.id, victor.id, 'Gitarr'::text)
    from
      dansdata.create_organization ('Casanovas') org,
      dansdata.create_individual ('Jimmy Lindberg') jimmy,
      dansdata.create_individual ('Henrik Sethsson') henrik,
      dansdata.create_individual ('Simon Bondesson') simon,
      dansdata.create_individual ('Stefan Ryding') stefan,
      dansdata.create_individual ('Victor Lindberg') victor
  ),
  _dansdata as (
    select
      org.id as org,
      felix.id as felix,
      dansdata.add_organization_member (org.id, felix.id, 'Utvecklare'::text)
    from
      dansdata.create_organization ('Dansdata') org,
      dansdata.create_individual ('Felix Zedén Yverås') felix
  ),
  nojeskallan as (
    select
      org.id as org,
      mats.id as mats,
      peter.id as peter,
      torbjorn.id as torbjorn,
      dansdata.add_organization_member (org.id, mats.id),
      dansdata.add_organization_member (org.id, peter.id),
      dansdata.add_organization_member (org.id, torbjorn.id)
    from
      dansdata.create_organization ('Nöjeskällan') org,
      dansdata.create_individual ('Mats Tigerström') mats,
      dansdata.create_individual ('Peter Rudenborg') peter,
      dansdata.create_individual ('Torbjörn Persson') torbjorn
  )
select
  *,
  dansdata.add_organization_member (nojeskallan.org, blender.org),
  dansdata.add_organization_member (nojeskallan.org, casanovas.org)
from
  blender,
  casanovas,
  _dansdata,
  nojeskallan;
