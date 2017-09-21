module PgHero
  module Methods
    module Citus
      def citus_version
        @citus_version ||= select_one("SHOW citus.version")
      end

      def citus_available?
        select_one("SELECT COUNT(*) AS count FROM pg_available_extensions WHERE name = 'citus'") > 0
      end

      # only cache if true
      def citus_enabled?
        @citus_enabled ||= citus_readable?
      end

      def citus_extension_enabled?
        select_one("SELECT COUNT(*) AS count FROM pg_extension WHERE extname = 'citus'") > 0
      end

      def citus_readable?
        select_all("SELECT 1 FROM pg_dist_partition LIMIT 1")
        true
      rescue ActiveRecord::StatementInvalid
        false
      end

      def nodes
        select_all <<-SQL
          SELECT placements.nodename AS name,
                 nodes.isactive AS status,
                 count(*) AS shard_count
          FROM pg_dist_shard_placement placements,
               pg_dist_node nodes
          WHERE placements.nodename = nodes.nodename
          GROUP BY placements.nodename, nodes.isactive
          ORDER BY 2 DESC, 3 DESC;
        SQL
      end
    end
  end
end

