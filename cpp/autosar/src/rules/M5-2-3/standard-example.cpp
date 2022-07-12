class Colour {/* ... */};
void setColour(Colour const &);
class Obj
{
  public:
    virtual bool hasColour() const = 0;
    virtual Colour getColour() const = 0;
};
class ObjWithColour : public Obj
{
  public:
    virtual bool hasColour() const
    {  
      return true;
    }
    virtual Colour getColour() const
    {
      return m_colour;
    } 
  private:
    Colour m_colour;
}; 
void badPrintObject(Obj const & obj)
{
  ObjWithColour const * pObj =
    dynamic_cast<ObjWithColour const*>(&obj); //Non-compliant
  if(0 != pObj)
  {
    setColour(pObj->getColour());
  } 
}
void goodPrintObject(Obj const & obj)
{
  if(obj.hasColour())
  {
    setColour(obj.getColour());
  } 
}