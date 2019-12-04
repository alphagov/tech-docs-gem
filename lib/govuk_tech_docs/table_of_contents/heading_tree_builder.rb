module GovukTechDocs
  module TableOfContents
    class HeadingTreeBuilder
      def initialize(headings)
        @headings = headings
        @tree = HeadingTree.new
        @pointer = @tree
      end

      def tree
        @headings.each do |heading|
          move_to_depth(heading.size)

          @pointer.children << HeadingTree.new(parent: @pointer, heading: heading)
        end

        remove_h1()

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

      def remove_h1()
        top_tree = HeadingTree.new
        @tree.children.each do |h1_tree|
          top_tree.heading = h1_tree.heading
          h1_tree.children.each do |h2_tree|
            top_tree.children.push(h2_tree)
            h2_tree.parent = top_tree
          end
        end

        @tree = top_tree
      end
    end
  end
end
