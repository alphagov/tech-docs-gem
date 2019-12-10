module GovukTechDocs
  module TableOfContents
    class HeadingTreeBuilder
      def initialize(headings, h1_as_root: false)
        @headings = headings
        @tree = HeadingTree.new
        @pointer = @tree
        @h1_as_root = h1_as_root
      end

      def tree
        @headings.each do |heading|
          move_to_depth(heading.size)

          @pointer.children << HeadingTree.new(parent: @pointer, heading: heading)
        end

        if @h1_as_root
          set_root_to_h1()
        end

        @tree
      end

    private

      def move_to_depth(depth)
        if depth > @pointer.depth
          @pointer = @pointer.children.last

          if depth > @pointer.depth
            @pointer.children << HeadingTree.new(parent: @pointer)

            move_to_depth(depth)
          end
        end

        if depth < @pointer.depth
          @pointer = @pointer.parent

          move_to_depth(depth)
        end
      end

      def set_root_to_h1()
        h1_children = @tree.children.select { |tree| tree.heading.size == 1 }

        if h1_children.length != 1
          raise "Cannot set table of contents root to H1. One H1 needed, #{h1_children.length} found"
        end

        h1 = h1_children.last
        root = HeadingTree.new(parent: nil, heading: h1.heading, children: h1.children)

        @tree = root
      end
    end
  end
end
