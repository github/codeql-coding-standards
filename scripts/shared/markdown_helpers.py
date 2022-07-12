from typing import *
from dataclasses import dataclass
from abc import abstractmethod, ABC
import re
import marko

@dataclass
class Update:
    """ An update to a Markdown document specified by a slice stating what is updated and content that describes what the slice is updated with. """
    slice: slice
    contents: List[Type[marko.element.Element]]


class UpdateSpec(ABC):
    """ An update specification that generates the updates for a given Markdown document. """

    @abstractmethod
    def generate_update(self, doc: Type[marko.block.Document]) -> Generator[Update, None, None]:
        pass

    def __call__(self, doc: Type[marko.block.Document]) -> Generator[Update, None, None]:
        return self.generate_update(doc)


class HeadingFormatUpdateSpec(UpdateSpec):
    """ An update specification that adds missing blank lines before and after headings. """

    def generate_update(self, doc: Type[marko.block.Document]) -> Generator[Update, None, None]:
        while True:
            for start,  start_elem in enumerate(doc.children):
                if start_elem.get_type() == 'Heading':
                    updates = []
                    if start > 0 and doc.children[start-1].get_type() != 'BlankLine':
                        updates.append(marko.block.BlankLine(0))
                    updates.append(start_elem)
                    if (start + 1) < len(doc.children) and doc.children[start+1].get_type() != 'BlankLine':
                        updates.append(marko.block.BlankLine(0))

                    if len(updates) > 1:
                        yield Update(slice(start, start + 1), updates)
            break


class HeadingSliceComputer:
    def __init__(self, heading: Union[str, re.Pattern]):
        self.heading = heading

    def _match(self, heading) -> bool:
        if isinstance(self.heading, str):
            return len(heading.children) > 0 and get_heading_text(heading) == self.heading
        elif isinstance(self.heading, re.Pattern):
            return self.heading.match(get_heading_text(heading)) != None
        else:
            raise "Invalid header update specification"

    def __call__(self, doc: Type[marko.block.Document]) -> Optional[slice]:
        for initial, initial_elem in enumerate(doc.children):
            if initial_elem.get_type() == 'Heading' and self._match(initial_elem):
                for end, end_elem in enumerate(doc.children[initial+1:]):
                    if end_elem.get_type() == 'Heading' and (end_elem.level <= initial_elem.level and initial_elem.level > 1 or initial_elem.level == 1):
                        return slice(initial, end+initial+1)
                return slice(initial, len(doc.children))
        return None


class HeadingDiffUpdateSpec(UpdateSpec):
    def __init__(self, heading: Union[str, re.Pattern], updated_doc: Type[marko.block.Document]):
        self.contents = updated_doc.children[HeadingSliceComputer(
            heading)(updated_doc)]
        self._slice_computer = HeadingSliceComputer(heading)

    def generate_update(self, doc: Type[marko.block.Document]) -> Generator[Update, None, None]:
        update_slice = self._slice_computer(doc)
        if update_slice:
            yield Update(update_slice, self.contents)

class HeadingReplaceSpec(UpdateSpec):
    def __init__(self, heading: Union[str, re.Pattern], replacement: List[marko.block.Element]):
        self.replacement = replacement
        self._slice_computer = HeadingSliceComputer(heading)

    def generate_update(self, doc: Type[marko.block.Document]) -> Generator[Update, None, None]:
        update_slice = self._slice_computer(doc)
        if update_slice:
            yield Update(update_slice, self.replacement)

def update_help_file(doc: Type[marko.block.Document], update_specs: List[UpdateSpec]) -> None:
    """Update help files by according to the update. """
    for update_spec in update_specs:
        for update in update_spec(doc):
            del doc.children[update.slice]
            doc.children[update.slice.start:
                         update.slice.start] = update.contents

def find_heading(doc: Type[marko.block.Document], heading: str) -> Optional[marko.block.Heading]:
    """ Find the first heading with the contents `heading` """
    for h in iterate_headings(doc):
        if get_heading_text(h) == heading:
            return h
    return None

def iterate_headings(doc: Type[marko.block.Document]) -> Generator[marko.block.Heading, None, None]: 
    for element in doc.children:
        if element.get_type() == 'Heading':
            yield element

def get_heading_text(heading: Type[marko.block.Heading]) -> str:
    return heading.children[0].children